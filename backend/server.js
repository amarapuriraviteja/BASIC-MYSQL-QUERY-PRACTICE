const express = require('express');
const cors = require('cors');
const getConnection = require('./db/connection');

const app = express();
app.use(cors());
app.use(express.json());

// GET all products
app.get('/products', async (req, res) => {
  try {
    const connection = await getConnection();
    const [rows] = await connection.execute('SELECT * FROM Products');
    await connection.end();
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST new product
app.post('/products', async (req, res) => {
  const { product_name, category, supplier_id, stock, price } = req.body;
  try {
    const connection = await getConnection();
    const query = 'INSERT INTO Products (product_name, category, supplier_id, stock, price) VALUES (?, ?, ?, ?, ?)';
    await connection.execute(query, [product_name, category, supplier_id, stock, price]);
    await connection.end();
    res.status(201).json({ message: 'Product added successfully' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.listen(5000, () => console.log('Backend running on port 5000'));
