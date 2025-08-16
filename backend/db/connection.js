const mysql = require('mysql2/promise');

const dbConfig = {
  host: 'localhost',
  user: 'root',
  password: 'MYSQL',
  database: 'ecommerce_project',
};

async function getConnection() {
  return await mysql.createConnection(dbConfig);
}

module.exports = getConnection;
