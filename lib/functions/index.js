// ==========================================
// functions/index.js
// Cloud Functions para proxy de APIs externas
// ==========================================

const functions = require('firebase-functions');
const admin = require('firebase-admin');
const axios = require('axios');
require('dotenv').config();

// Inicializa o Firebase Admin (seguro mesmo que já inicializado)
try {
  admin.initializeApp();
} catch (e) {
  // ignore if already initialized in emulator/runtime
}

// Utilitário simples de CORS preflight handling
function handleCors(req, res) {
  res.set('Access-Control-Allow-Origin', '*');
  res.set('Access-Control-Allow-Headers', 'Content-Type');
  res.set('Access-Control-Allow-Methods', 'GET,POST,OPTIONS');
  if (req.method === 'OPTIONS') {
    res.status(204).send('');
    return true;
  }
  return false;
}

// ========== Função: getExchangeRates ==========
exports.getExchangeRates = functions.https.onRequest(async (req, res) => {
  if (handleCors(req, res)) return;

  try {
    const apiKey = process.env.EXCHANGE_API_KEY;
    if (!apiKey) throw new Error('API key não configurada');

    const url = `https://www.alphavantage.co/query?function=CURRENCY_EXCHANGE_RATE&from_currency=USD&to_currency=BRL&apikey=${apiKey}`;
    const response = await axios.get(url);
    const exchangeRate = response.data && response.data['Realtime Currency Exchange Rate'];
    if (!exchangeRate) throw new Error('Erro ao obter cotações');

    const rates = {
      USD: parseFloat(exchangeRate['5. Exchange Rate']) || null,
    };

    res.status(200).json({
      success: true,
      timestamp: Date.now(),
      rates: rates,
    });
  } catch (error) {
    console.error('Erro ao buscar cotações:', error && error.response ? error.response.data || error.message : error.message || error);
    res.status(500).json({
      success: false,
      error: 'Erro ao buscar cotações de câmbio',
      details: error.message || String(error),
    });
  }
});

// ========== Função: getNews ==========
exports.getNews = functions.https.onRequest(async (req, res) => {
  if (handleCors(req, res)) return;

  try {
    const apiKey = process.env.NEWS_API_KEY;
    if (!apiKey) throw new Error('News API key não configurada');

    const category = req.query.category || 'business';
    const country = req.query.country || 'br';
    const pageSize = parseInt(req.query.pageSize, 10) || 10;

    const url = `https://newsapi.org/v2/top-headlines?category=${encodeURIComponent(category)}&country=${encodeURIComponent(country)}&pageSize=${pageSize}&apiKey=${apiKey}`;
    const response = await axios.get(url);

    if (!response.data || response.data.status !== 'ok') {
      throw new Error('Erro ao buscar notícias');
    }

    const articles = (response.data.articles || []).map(article => ({
      title: article.title || null,
      description: article.description || null,
      url: article.url || null,
      urlToImage: article.urlToImage || null,
      publishedAt: article.publishedAt || null,
      source: article.source && article.source.name ? article.source.name : null,
    }));

    res.status(200).json({
      success: true,
      totalResults: response.data.totalResults || articles.length,
      articles: articles,
    });
  } catch (error) {
    console.error('Erro ao buscar notícias:', error && error.response ? error.response.data || error.message : error.message || error);
    res.status(500).json({
      success: false,
      error: 'Erro ao buscar notícias',
      details: error.message || String(error),
    });
  }
});