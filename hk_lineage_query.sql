select  bo.user_id AS customer_id,
       ols.wms_variant_id AS product_variant_id,
       ptc.name as payment_type,bo.applied_offer_id AS promotion_id,
       ols.combo_id,NVL(sku.warehouse_id,-1) AS warehouse_id, --add sku table
	   NVL(pd.supplier_id,-2) AS supplier_id, NVL(ols.bo_store_id,-1) as store_id,
       NVL(bo.address_id,-1) AS address_id,NVL(pin.pincode,'-2') as pincode_id,
       NVL(sku.id,-2) AS sku_id,li.id AS line_item_id,
       ols.cart_line_item_id AS cart_line_item_id,-1 AS Subscription_Id,
	   NULL AS Cart_Line_Item_Config_Id,bo.id AS order_id,
       bo.gateway_order_id AS gateway_order_id,so.id AS shipping_order_id,
	   sh.id AS shipment_id,bos.Name AS base_order_status,
	   sos.name AS shipping_order_status,ps.Name AS payment_status,
	   'CFA' AS Order_type,null AS inventory_type,
       (case when pd.drop_shipping=1 then 'dropship' else 'notdropship' end) AS  shipping_type,
       NULL AS cancellation_remark, NULL AS cancellation_type,
       so.basket_category AS basket_category,
	   (case when ols.variant_in_cart_as=20 then 'free' else 'priced' end) as line_item_type,
       -- (case when pv.free_product_variant_id is null then 'priced' else 'free' end) AS line_item_type,
	   NULL AS order_confirmation_dt,NVL(p.payment_dt,bo.create_dt) payment_dt,
       DATEADD(day,pd.min_days,date(p.payment_dt)) as Target_Min_Dispatch_Date,DATEADD(day,pd.max_days,date(p.payment_dt)) as Target_Max_Dispatch_Date,
       NULL as Target_Min_Dispatch_Auth_Date,NULL as Target_Max_Dispatch_Auth_Date,
       ols.sp_target_del_dt AS target_min_del_dt,ols.sp_target_del_dt AS target_max_del_dt,
       NULL as Target_MIn_Del_Date_Verify_Date,NULL as Target_Max_Del_Date_Verify_Date,
       NULL AS next_subscr_order_dt,NULL AS subscr_status,
       NULL AS subscr_qty_per_delivery,NULL AS subscr_period,
       NULL AS subscr_frequency,NULL AS subscr_dscnt_percent,
       NULL AS subscr_hk_dscnt,NULL AS subscr_hk_price,
       NULL AS subscr_hk_cost_price,NULL AS subscr_qty,
       NULL AS subscr_start_dt,NULL AS subscr_next_ship_dt,
	   ols.sp_ship_dt AS ship_dt,ols.sp_delivery_dt AS delivery_dt,
       ols.olr_return_dt AS return_dt,NULL AS rto_dt,
       NULL AS rpo_dt,ols.mrp AS oli_unit_marked_price,
       -- ols.offer_price AS oli_unit_hk_price,-- renamed to Oli_Total_Offer_Price
		ols.offer_price AS Oli_Total_Offer_Price, -- renamed column
       (CASE WHEN ols.cost_price is null then 0 else ols.cost_price end ) AS oli_unit_cost_price,
       (CASE WHEN upper(wh.state) = 'HARYANA' then
				NVL(tax.value,0)*1.05/ (1 + NVL(tax.value,0)*1.05)
			 else NVL(tax.value,0) / (1 + NVL(tax.value,0))
		end) * (ols.offer_price-ols.discount_on_offer_price-ols.order_level_discount+ols.shipping_charge+ols.cod_charge) AS oli_unit_tax_amount,
	   0 AS oli_postpaid_amt,
	   NVL(ols.shipping_charge,0) AS oli_shipping_charge,
	   NVL(ols.cod_charge,0) AS oli_cod_charge,
	   NVL(wrlt.shipment_charge,0)/li.qty AS oli_shipping_cost,
	   NVL(wrlt.collection_charge,0)/li.qty AS oli_collection_cost,
	   NVL(wrlt.estm_shipment_charge,0)/li.qty AS oli_estimated_shipping_cost,
	   NVL(wrlt.estm_collection_charge,0)/li.qty AS oli_estimated_collection_cost,
	   NVL(wrlt.extra_charge,0)/li.qty AS oli_estimated_packaging_cost,
	   (NVL(wrlt.estm_shipment_charge,0)+NVL(wrlt.estm_collection_charge,0)+NVL(wrlt.extra_charge,0))/li.qty as oli_estimated_delivery_cost,	
	   0 AS warehouse_cost,
	   0 AS cust_care_cost,
	   0 AS marketing_spent,
       ols.discount_on_offer_price AS oli_hk_disc_price,
       ols.order_level_discount AS oli_order_dscnt_price,
	   0 AS Oli_Earned_Rp_Used_Num,
	   0 AS Oli_Prepay_Rp_Used_Num,
	   0 AS Oli_Total_Rp_Used_Num,
       ols.reward_point_discount,
       1 AS oli_purchased_qty,
       ols.mrp AS oli_total_marked_price,
       -- ols.offer_price AS oli_total_hk_price,--set ols.hk_price
		ols.hk_price AS oli_total_hk_price, -- newly set
       (ols.offer_price-ols.discount_on_offer_price-ols.order_level_discount+ols.shipping_charge+ols.cod_charge) AS oli_net_paid_amt,
       (ols.offer_price-ols.discount_on_offer_price-ols.order_level_discount+ols.shipping_charge+ols.cod_charge) AS oli_net_sale,
       (CASE WHEN ols.cost_price is null then 0 else ols.cost_price end ) AS oli_total_prod_cost,
/*       (CASE WHEN upper(wh.state) = 'HARYANA' then
				NVL(tax.value,0)*1.05/ (1 + NVL(tax.value,0)*1.05)
			 else NVL(tax.value,0) / (1 + NVL(tax.value,0))
		end) * (ols.offer_price-ols.discount_on_offer_price-ols.order_level_discount+ols.shipping_charge+ols.cod_charge) AS oli_total_tax_amount,*/
(CASE WHEN date(ols.sp_ship_dt) < '2017-07-01' then 
(case when upper(wh.state) = 'HARYANA' then NVL(tax.value,0)*1.05/ (1 + NVL(tax.value,0)*1.05) else NVL(tax.value,0) / (1 + NVL(tax.value,0))
end) else  ((NVL(cgst,0)+NVL(sgst,0)+NVL(igst,0))/(1+(NVL(cgst,0)+NVL(sgst,0)+NVL(igst,0)))) end)
* (ols.offer_price-ols.discount_on_offer_price-ols.order_level_discount+ols.shipping_charge+ols.cod_charge) AS oli_total_tax_amount,
       (ols.offer_price-ols.discount_on_offer_price-ols.order_level_discount+ols.shipping_charge+ols.cod_charge)
       -(CASE WHEN ols.cost_price is null then 0 else ols.cost_price end)
       -((CASE WHEN upper(wh.state) = 'HARYANA' then
				NVL(tax.value,0)*1.05/ (1 + NVL(tax.value,0)*1.05)
			 else NVL(tax.value,0) / (1 + NVL(tax.value,0))
		end) * (ols.offer_price-ols.discount_on_offer_price-ols.order_level_discount+ols.shipping_charge+ols.cod_charge))
        - ((NVL(wrlt.shipment_charge,NVL(wrlt.shipment_charge,0))+NVL(wrlt.extra_charge,0)+NVL(wrlt.collection_charge,NVL(wrlt.collection_charge,0)))/li.qty) as oli_net_profit, ---veriy
/*       (ols.offer_price-ols.discount_on_offer_price-ols.order_level_discount+ols.shipping_charge+ols.cod_charge)
       -(CASE WHEN ols.cost_price is null then 0 else ols.cost_price end)
       -((CASE WHEN upper(wh.state) = 'HARYANA' then
				NVL(tax.value,0)*1.05/ (1 + NVL(tax.value,0)*1.05)
			 else NVL(tax.value,0) / (1 + NVL(tax.value,0))
		end) * (ols.offer_price-ols.discount_on_offer_price-ols.order_level_discount+ols.shipping_charge+ols.cod_charge)) as oli_gross_profit,*/
(ols.offer_price-ols.discount_on_offer_price-ols.order_level_discount+ols.shipping_charge+ols.cod_charge)
 -(CASE WHEN ols.cost_price is null then 0 else ols.cost_price end)
 -((CASE WHEN date(ols.sp_ship_dt) < '2017-07-01' then 
(case when upper(wh.state) = 'HARYANA' then NVL(tax.value,0)*1.05/ (1 + NVL(tax.value,0)*1.05) else NVL(tax.value,0) / (1 + NVL(tax.value,0))
end) else  ((NVL(cgst,0)+NVL(sgst,0)+NVL(igst,0))/(1+(NVL(cgst,0)+NVL(sgst,0)+NVL(igst,0)))) end) * (ols.offer_price-ols.discount_on_offer_price-ols.order_level_discount+ols.shipping_charge+ols.cod_charge)) as oli_gross_profit,
	   0 AS Oli_Ebit,
	   0 AS Oli_Gross_Profit_Post_Marketing,
       NULL AS Attr1,
	   NULL AS Attr2,
	   NULL AS Attr3,
       p.id AS payment_id,
       ols.vendor_id AS vendor_id,
       ols.opr_id AS opr_id,
       ols.id as opr_li_id,
       oss.Name AS opr_status,
       olss.Name AS opr_li_status,
       bo.applied_offer_id,
       upper(bo.applied_coupon_code) as applied_coupon_code,
       bo.store_id as cat_store_id,
	   NULL as cancel_dt,
	   ols.olr_return_initiated_dt,
	   NULL as rto_initiated_dt,
	   ols.sp_awb_no as awb_number,
	   ols.sp_courier_name as courier_name,
	   rt.name as return_type,
	   ols.bo_address_id as hkr_address_id,
	   usr.login as login,
	   li.cgst,
	   li.sgst,
	   li.igst,
	   so.pack_date,
	   so.status_update_date,
	   so.first_esc_date,
	   ols.trainer_earning,
	   ols.return_reason
FROM staging_catalogue.fact_sales_prod_cfa_temp ols
JOIN bo ON (bo.id=ols.base_order_id) 
JOIN dd_catalogue.dd_user usr ON (bo.user_id=usr.id)
JOIN dd_catalogue.dd_payment p ON (p.id=bo.payment_id)
JOIN dd_catalogue.dd_address ad ON (ad.id=bo.address_id)
JOIN dd_catalogue.dd_pincode pin on (ad.pincode_id=pin.id)
JOIN hcoli ON (ols.id = hcoli.host_opr_li_id)
JOIN li ON (ols.id = li.host_opr_li_id) and li.qty>0
--JOIN dd_prod.dd_host_cli_opr_li_hkr hcoli ON (ols.id=hcoli.host_opr_li_id)
-- JOIN dd_prod.dd_line_item_hkr li on li.cart_line_item_id=hcoli.cart_line_item_id and li.id=hcoli.line_item_id
--JOIN dd_prod.dd_line_item_hkr li on (case when hcoli.line_item_id is null then li.cart_line_item_id=hcoli.cart_line_item_id
--else li.id=hcoli.line_item_id end) and li.qty>0
--JOIN dd_prod.dd_line_item_hkr li on (li.id=hcoli.line_item_id or li.cart_line_item_id=hcoli.cart_line_item_id) and li.qty>0
JOIN dd_prod.dd_sku_hkr sku on sku.id=li.sku_id
left JOIN dd_prod.dd_tax_hkr tax on li.tax_id=tax.id
JOIN dd_prod.dd_shipping_order_hkr so on li.shipping_order_id=so.id
JOIN dd_prod.dd_warehouse_hkr wh on sku.warehouse_id=wh.id
LEFT OUTER JOIN dd_prod.dd_shipment_hkr sh on sh.id=so.shipment_id
LEFT OUTER JOIN dd_prod.dd_shipping_order_status_hkr sos on sos.id=so.shipping_order_status_id
JOIN staging_catalogue.base_order_status bos on (bo.base_order_status_id=bos.id)
JOIN staging_catalogue.opr_li_status olss ON (ols.status=olss.id)
JOIN staging_catalogue.opr_status oss ON (ols.opr_status=oss.id)
JOIN staging_catalogue.payment_status ps ON (p.status=ps.ID)
JOIN staging_catalogue.variant_in_cart vic ON (ols.variant_in_cart_as=vic.id)
JOIN staging_catalogue.payment_type_cat ptc ON (p.payment_type=ptc.ID)
left outer JOIN staging_catalogue.return_type rt ON (ols.olr_return_type=rt.ID)
left join (select id,line_item_id,NVL(shipment_charge,estm_shipment_charge)as shipment_charge ,
NVL(collection_charge,estm_collection_charge)as collection_charge,
NVL(estm_shipment_charge,0)as estm_shipment_charge,NVL(estm_collection_charge,0)as estm_collection_charge,
extra_charge
from dd_prod.dd_wh_report_line_item_hkr) wrlt on li.id = wrlt.line_item_id 
left join dd_prod.dd_product_variant_hkr pv on upper(pv.id)=upper(ols.wms_variant_id)
left join dd_prod.dd_product_hkr pd on upper(pd.id)=upper(pv.product_id);
