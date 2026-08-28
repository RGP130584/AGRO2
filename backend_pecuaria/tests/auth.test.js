process.env.JWT_SECRET = 'test_secret';
const request = require('supertest');
const app = require('../app');

describe('Auth Endpoints', () => {
  const testUser = {
    nome: 'User Test',
    cpfCnpj: '12345678901',
    senha: 'password123',
    email: 'test@example.com'
  };

  it('should register a new user', async () => {
    // Para contornar problema de cpf já existir rodando testes multiplas vezes
    testUser.cpfCnpj = Math.floor(10000000000 + Math.random() * 90000000000).toString();
    const res = await request(app)
      .post('/v1/auth/register')
      .send(testUser);
      
    expect(res.statusCode).toEqual(201);
    expect(res.body).toHaveProperty('token');
    expect(res.body.user).toHaveProperty('id');
  });

  it('should login an existing user', async () => {
    const res = await request(app)
      .post('/v1/auth/login')
      .send({
        cpfCnpj: testUser.cpfCnpj,
        senha: testUser.senha
      });
      
    expect(res.statusCode).toEqual(200);
    expect(res.body).toHaveProperty('token');
  });

  it('should request a password reset', async () => {
    const res = await request(app)
      .post('/v1/auth/password-reset/request')
      .send({
        email: testUser.email
      });
      
    expect(res.statusCode).toEqual(200);
  });
});
