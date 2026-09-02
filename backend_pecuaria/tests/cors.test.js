process.env.NODE_ENV = 'test';
process.env.JWT_SECRET = 'test_secret_for_automated_testing_12345';
process.env.CORS_ORIGINS = 'http://localhost:3000,http://app.agro.com';

const request = require('supertest');
const app = require('../app');

describe('CORS Whitelist & Security Tests', () => {
  it('deve permitir requisições com Origin autorizado', async () => {
    const res = await request(app)
      .get('/v1/auth/login')
      .set('Origin', 'http://app.agro.com');

    // CORS aceito define o header Access-Control-Allow-Origin
    expect(res.headers['access-control-allow-origin']).toBe('http://app.agro.com');
  });

  it('deve permitir requisições sem header Origin (apps mobile, CLI, curl)', async () => {
    const res = await request(app).get('/v1/auth/login');
    // Não deve estourar erro de CORS
    expect(res.status).not.toBe(500);
  });

  it('deve rejeitar requisições de origens não autorizadas', async () => {
    const res = await request(app)
      .get('/v1/auth/login')
      .set('Origin', 'http://malicious-site.com');

    // Origem não permitida não deve receber o header Access-Control-Allow-Origin do site malicioso
    expect(res.headers['access-control-allow-origin']).toBeUndefined();
  });
});
