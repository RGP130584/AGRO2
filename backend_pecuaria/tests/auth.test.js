process.env.NODE_ENV = 'test';
process.env.JWT_SECRET = 'test_secret_for_automated_testing_12345';
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
    testUser.cpfCnpj = Math.floor(10000000000 + Math.random() * 90000000000).toString();
    testUser.email = `user_${testUser.cpfCnpj}@example.com`;
    
    const res = await request(app)
      .post('/v1/auth/register')
      .send(testUser);
      
    expect(res.statusCode).toEqual(201);
    expect(res.body).toHaveProperty('token');
    expect(res.body.user).toHaveProperty('id');
    expect(res.body.user.perfil).toEqual('proprietario');
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
