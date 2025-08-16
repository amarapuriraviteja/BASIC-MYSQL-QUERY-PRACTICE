import React, { useState, useEffect } from 'react';

export default function AddProduct() {
  const [products, setProducts] = useState([]);
  const [form, setForm] = useState({
    product_name: '',
    category: '',
    supplier_id: '',
    stock: '',
    price: ''
  });

  useEffect(() => {
    fetchProducts();
  }, []);

  const fetchProducts = async () => {
    const res = await fetch('http://localhost:5000/products');
    const data = await res.json();
    setProducts(data);
  };

  const handleChange = (e) => setForm({ ...form, [e.target.name]: e.target.value });

  const handleSubmit = async () => {
    await fetch('http://localhost:5000/products', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(form)
    });
    alert('Product added!');
    fetchProducts(); // Refresh list
  };

  return (
    <div>
      <h2>Add New Product</h2>
      <input placeholder="Name" name="product_name" onChange={handleChange} />
      <input placeholder="Category" name="category" onChange={handleChange} />
      <input placeholder="Supplier ID" name="supplier_id" onChange={handleChange} />
      <input placeholder="Stock" name="stock" onChange={handleChange} />
      <input placeholder="Price" name="price" onChange={handleChange} />
      <button onClick={handleSubmit}>Add Product</button>

      <h2>Existing Products</h2>
      <ul>
        {products.map((p) => (
          <li key={p.product_id}>
            {p.product_name} - ₹{p.price} - Stock: {p.stock}
          </li>
        ))}
      </ul>
    </div>
  );
}
