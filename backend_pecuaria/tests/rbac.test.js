process.env.NODE_ENV = 'test';
process.env.JWT_SECRET = 'test_secret_for_automated_testing_12345';
const request = require('supertest');
const app = require('../app');

describe('RBAC Authorization Tests', () => {
    let ownerToken;
    let employeeToken;

    beforeAll(async () => {
        // Registrar um proprietário
        const ownerRes = await request(app)
            .post('/v1/auth/register')
            .send({
                nome: 'Proprietario Teste',
                cpfCnpj: '33344455566',
                email: 'owner@teste.com',
                senha: 'senhaOwner123',
                perfil: 'proprietario'
            });
        ownerToken = ownerRes.body.token;

        // Registrar um funcionário
        const empRes = await request(app)
            .post('/v1/auth/register')
            .send({
                nome: 'Funcionario Teste',
                cpfCnpj: '77788899900',
                email: 'emp@teste.com',
                senha: 'senhaEmp123',
                perfil: 'funcionario'
            });
        employeeToken = empRes.body.token;
    });

    test('Proprietario pode listar usuarios via /v1/users', async () => {
        const res = await request(app)
            .get('/v1/users')
            .set('Authorization', `Bearer ${ownerToken}`);

        expect(res.statusCode).toBe(200);
        expect(Array.isArray(res.body)).toBe(true);
        expect(res.body.length).toBeGreaterThanOrEqual(2);
    });

    test('Funcionario recebe 403 Forbidden ao tentar listar usuarios via /v1/users', async () => {
        const res = await request(app)
            .get('/v1/users')
            .set('Authorization', `Bearer ${employeeToken}`);

        expect(res.statusCode).toBe(403);
        expect(res.body.error).toBe('Acesso negado para o perfil do usuário.');
    });

    test('Proprietario pode cadastrar funcionario via /v1/users/invite', async () => {
        const res = await request(app)
            .post('/v1/users/invite')
            .set('Authorization', `Bearer ${ownerToken}`)
            .send({
                nome: 'Novo Vaqueiro',
                cpfCnpj: '99988877766',
                email: 'vaqueiro@teste.com',
                senha: 'senhaVaqueiro123',
                perfil: 'funcionario'
            });

        expect(res.statusCode).toBe(201);
        expect(res.body.user.perfil).toBe('funcionario');
    });

    test('Funcionario recebe 403 Forbidden ao tentar cadastrar outro usuario via /v1/users/invite', async () => {
        const res = await request(app)
            .post('/v1/users/invite')
            .set('Authorization', `Bearer ${employeeToken}`)
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
});
