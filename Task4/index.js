// index.js
const express = require('express');
const app = express();
const port = 3000; // You can change the port if needed

// Define a route for the root URL
app.get('/', (req, res) => {
  res.send('Hello from microservice-testing');
});

// Start the server
app.listen(port, () => {
  console.log(`Server running at http://localhost:${port}`);
});
