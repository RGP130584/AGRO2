process.env.NODE_ENV = 'test';
process.env.JWT_SECRET = 'test_secret_for_automated_testing_12345';
const request = require('supertest');
const app = require('../app');

describe('RBAC Authorization & Team Privacy Tests', () => {
    let ownerAToken;
    let ownerBToken;
    let employeeAToken;

    beforeAll(async () => {
        // Registrar Proprietário A
        const ownerARes = await request(app)
            .post('/v1/auth/register')
            .send({
                nome: 'Proprietario Fazenda Alfa',
                cpfCnpj: '33344455566',
                email: 'ownerA@teste.com',
                senha: 'senhaOwner123',
                perfil: 'proprietario'
            });
        ownerAToken = ownerARes.body.token;

        // Registrar Proprietário B (Outra Fazenda/Tenant)
        const ownerBRes = await request(app)
            .post('/v1/auth/register')
            .send({
                nome: 'Proprietario Fazenda Beta',
                cpfCnpj: '44455566677',
                email: 'ownerB@teste.com',
                senha: 'senhaOwner123',
                perfil: 'proprietario'
            });
        ownerBToken = ownerBRes.body.token;

        // Proprietário A convida um funcionário para a sua equipe
        const inviteRes = await request(app)
            .post('/v1/users/invite')
            .set('Authorization', `Bearer ${ownerAToken}`)
            .send({
                nome: 'Vaqueiro da Fazenda Alfa',
                cpfCnpj: '77788899900',
                email: 'vaqueiroA@teste.com',
                senha: 'senhaEmp123',
                perfil: 'funcionario'
            });
        expect(inviteRes.statusCode).toBe(201);

        // Funcionário A faz login
        const empLoginRes = await request(app)
            .post('/v1/auth/login')
            .send({
                cpfCnpj: '77788899900',
                senha: 'senhaEmp123'
            });
        employeeAToken = empLoginRes.body.token;
    });

    test('Proprietario A lista apenas os usuarios da sua propria conta/equipe', async () => {
        const res = await request(app)
            .get('/v1/users')
            .set('Authorization', `Bearer ${ownerAToken}`);

        expect(res.statusCode).toBe(200);
        expect(Array.isArray(res.body)).toBe(true);
        // Deve conter Proprietario A e seu Vaqueiro
        expect(res.body.length).toBe(2);
        expect(res.body.map(u => u.cpfCnpj)).toContain('33344455566');
        expect(res.body.map(u => u.cpfCnpj)).toContain('77788899900');
        // NUNCA deve conter o Proprietario B
        expect(res.body.map(u => u.cpfCnpj)).not.toContain('44455566677');
    });

    test('Proprietario B lista apenas a si mesmo (sem ver a equipe de A)', async () => {
        const res = await request(app)
            .get('/v1/users')
            .set('Authorization', `Bearer ${ownerBToken}`);

        expect(res.statusCode).toBe(200);
        expect(res.body.length).toBe(1);
        expect(res.body[0].cpfCnpj).toBe('44455566677');
    });

    test('Funcionario recebe 403 Forbidden ao tentar listar usuarios via /v1/users', async () => {
        const res = await request(app)
            .get('/v1/users')
            .set('Authorization', `Bearer ${employeeAToken}`);

        expect(res.statusCode).toBe(403);
        expect(res.body.error).toBe('Acesso negado para o perfil do usuário.');
    });

    test('Funcionario recebe 403 Forbidden ao tentar cadastrar outro usuario via /v1/users/invite', async () => {
        const res = await request(app)
            .post('/v1/users/invite')
            .set('Authorization', `Bearer ${employeeAToken}`)
            .send({
                nome: 'Tentativa Negada',
                cpfCnpj: '00011122233',
                email: 'negado@teste.com',
                senha: 'senhaNegada123',
                perfil: 'funcionario'
            });

        expect(res.statusCode).toBe(403);
        expect(res.body.error).toBe('Acesso negado para o perfil do usuário.');
    });

    test('Funcionario sincroniza dados na mesma conta do Proprietario A', async () => {
        const entityId = 'animal-123-alfa';
        // Vaqueiro envia um registro de animal na conta da Fazenda Alfa
        const pushRes = await request(app)
            .post('/v1/sync')
            .set('Authorization', `Bearer ${employeeAToken}`)
            .send({
                outbox: [{
                    id: 1,
                    entityType: 'animais',
                    entityId: entityId,
                    action: 'insert',
                    payload: { id: entityId, brinco: 'BR-100', raca: 'Nelore' },
                    deviceId: 'device-vaqueiro',
                    createdAt: new Date().toISOString()
                }],
                lastSyncAt: "1970-01-01T00:00:00.000Z"
            });
        expect(pushRes.statusCode).toBe(200);

        // Proprietario A faz sync e recebe a alteração feita pelo seu funcionário
        const pullResA = await request(app)
            .post('/v1/sync')
            .set('Authorization', `Bearer ${ownerAToken}`)
            .send({
                outbox: [],
                lastSyncAt: "1970-01-01T00:00:00.000Z"
            });
        expect(pullResA.statusCode).toBe(200);
        const animalRecebido = pullResA.body.changes.find(c => c.entityId === entityId);
        expect(animalRecebido).toBeDefined();
        expect(animalRecebido.payload.brinco).toBe('BR-100');

        // Proprietário B (Outra Fazenda) faz sync e NÃO recebe o animal da Fazenda Alfa
        const pullResB = await request(app)
            .post('/v1/sync')
            .set('Authorization', `Bearer ${ownerBToken}`)
            .send({
                outbox: [],
                lastSyncAt: "1970-01-01T00:00:00.000Z"
            });
        expect(pullResB.statusCode).toBe(200);
        const animalEmB = pullResB.body.changes.find(c => c.entityId === entityId);
        expect(animalEmB).toBeUndefined();
    });
});
