-- Report 1: Product Listing
-- Lists all products with: ID, Name, Product Category, Track inventory, Type, Sales Price, Cost, Tax
-- 
-- Note: This report uses product_template as the base since it contains most product information.

SELECT 
    pt.id AS "Product ID",
    pt.name->>'en_US' AS "Product Name",
    COALESCE(pc.name, 'Uncategorized') AS "Product Category",
    CASE 
        WHEN pt.tracking = 'none' THEN 'No'
        WHEN pt.tracking = 'lot' THEN 'Yes (Lot)'
        WHEN pt.tracking = 'serial' THEN 'Yes (Serial)'
        ELSE pt.tracking
    END AS "Track Inventory",
    CASE 
        WHEN pt.type = 'consu' THEN 'Consumable'
        WHEN pt.type = 'service' THEN 'Service'
        WHEN pt.type = 'product' THEN 'Storable Product'
        ELSE pt.type
    END AS "Product Type",
    COALESCE(pt.list_price, 0) AS "Sales Price",
    COALESCE(
        (SELECT (pp.standard_price->>'en_US')::numeric 
         FROM product_product pp 
         WHERE pp.product_tmpl_id = pt.id 
         LIMIT 1), 
        0
    ) AS "Cost",
    COALESCE(
        STRING_AGG(DISTINCT at.name->>'en_US', ', '), 
        'No Tax'
    ) AS "Tax"
FROM 
    product_template pt
    LEFT JOIN product_category pc ON pt.categ_id = pc.id
    LEFT JOIN product_taxes_rel ptr ON pt.id = ptr.prod_id
    LEFT JOIN account_tax at ON ptr.tax_id = at.id
WHERE 
    pt.active = true
GROUP BY 
    pt.id, 
    pt.name, 
    pc.name, 
    pt.tracking, 
    pt.type, 
    pt.list_price
ORDER BY 
    pt.id;
