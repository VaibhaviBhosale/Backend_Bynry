const express = require('express');
const router = express.Router();

// GET /api/companies/:company_id/alerts/low-stock
router.get('/api/companies/:company_id/alerts/low-stock', async (req, res) => {
  const companyId = parseInt(req.params.company_id, 10);

  if (!companyId || companyId < 1) {
    return res.status(400).json({ error: 'Invalid company id provided' });
  }

  const recentDate = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000);

  try {
    const results = await db.query(`
      SELECT
        p.id AS product_id,
        p.name AS product_name,
        p.sku,
        w.id AS warehouse_id,
        w.name AS warehouse_name,
        i.quantity AS stock_available,
        p.low_stock_threshold AS threshold,
        SUM(s.quantity) AS total_sales,
        COUNT(DISTINCT DATE(s.sale_date)) AS sales_days,
        sup.id AS supplier_id,
        sup.name AS supplier_name,
        sup.contact_email
      FROM products p
      JOIN inventory i ON p.id = i.product_id
      JOIN warehouses w ON w.id = i.warehouse_id
      JOIN sales s ON s.product_id = p.id
                   AND s.warehouse_id = w.id
                   AND s.sale_date >= ?
      LEFT JOIN product_suppliers ps ON ps.product_id = p.id
      LEFT JOIN suppliers sup ON sup.id = ps.supplier_id
      WHERE p.company_id = ?
        AND w.company_id = ?
        AND i.quantity < p.low_stock_threshold
      GROUP BY p.id, w.id, sup.id
      ORDER BY i.quantity ASC
    `, [recentDate, companyId, companyId]);

    const alerts = results.map(row => {
      let daysUntilStockout = null;

      if (row.sales_days > 0 && row.total_sales > 0) {
        const avgDailySales = row.total_sales / row.sales_days;
        daysUntilStockout = Math.ceil(row.stock_available / avgDailySales);
      }

      return {
        product_id: row.product_id,
        product_name: row.product_name,
        sku: row.sku,
        warehouse_id: row.warehouse_id,
        warehouse_name: row.warehouse_name,
        current_stock: row.stock_available,
        threshold: row.threshold,
        days_until_stockout: daysUntilStockout,
        supplier: row.supplier_id
          ? {
              id: row.supplier_id,
              name: row.supplier_name,
              contact_email: row.contact_email
            }
          : null
      };
    });

    return res.json({
      alerts,
      total_alerts: alerts.length
    });

  } catch (error) {
    console.error('Error generating low-stock alerts:', error);
    return res.status(500).json({ error: 'Failed to fetch low-stock alerts' });
  }
});

module.exports = router;