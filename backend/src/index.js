const express = require('express');
const dotenv = require('dotenv');

dotenv.config();

const app = express();
const port = process.env.PORT || 3000;

app.use(express.json());

// Rotta di esempio
app.get('/api', (req, res) => {
  res.json({ message: 'Benvenuto nell\'API di Kilwinning!' });
});

app.listen(port, () => {
  console.log(`Server avviato su http://localhost:${port}`);
});
