-- Report 2: Onhand Stock Quantity by Product
-- Shows the total onhand quantity for each product across all internal locations
--
-- Note: This report uses product_product (variants) as the base since stock is tracked at variant level.


SELECT 
    pp.id AS "Product Variant ID",
    pt.id AS "Product Template ID",
    pt.name->>'en_US' AS "Product Name",
    COALESCE(pp.default_code, '') AS "Internal Reference",
    COALESCE(pp.barcode, '') AS "Barcode",
    COALESCE(SUM(sq.quantity), 0) AS "Onhand Quantity",
    COALESCE(SUM(sq.reserved_quantity), 0) AS "Reserved Quantity",
    COALESCE(SUM(sq.quantity) - SUM(sq.reserved_quantity), 0) AS "Available Quantity"
FROM 
    product_product pp
    INNER JOIN product_template pt ON pp.product_tmpl_id = pt.id
    LEFT JOIN stock_quant sq ON pp.id = sq.product_id
    LEFT JOIN stock_location sl ON sq.location_id = sl.id
WHERE 
    pp.active = true
    AND pt.active = true
    AND (sl.usage = 'internal' OR sl.usage IS NULL)
GROUP BY 
    pp.id, 
    pt.id, 
    pt.name, 
    pp.default_code, 
    pp.barcode
ORDER BY 
    pt.id, 
    pp.id;
