create table online_fact_order_payments as (
--select * from (
select distinct     
pt.id as payment_id,
pt.order_id,
pt.billing_address_id,
pt.payment_mode_id,
pt.gateway_order_id as lookup,
pt.payment_status_id,
pt.amount,
pt.payment_date,
pt.cheque_number,
pt.refund_amount,
pt.response_message,
case when pm.name in ('cod','counter cash','offline payment') then 'cod' else pm.name end as payment_mode_name,
g.name gateway,
i.name issuer_name,
it.name issuer_type,
ba.serial_no tin,
ba.serial_no customer_gstin
from dd_prod.dd_payment_hkr pt
left JOIN dd_prod.dd_payment_mode_hkr pm ON pt.payment_mode_id=pm.id and (pm.operation is null or pm.operation in('U','I')) 
left join dd_catalogue.dd_base_order dbo on dbo.gateway_order_id  = pt.gateway_order_id 
LEFT JOIN dd_hkpay.dd_payment_request pr ON pr.order_id = dbo.gateway_order_id 
left outer join dd_hkpay.dd_gateway g on g.id = pr.gateway_id
left outer join dd_hkpay.dd_issuer i on i.id = pr.issuer_id
left outer join dd_hkpay.dd_issuer_type it on it.id = i.issuer_type_id
left join dd_prod.dd_billing_address ba on pt.billing_address_id = ba.billing_address_id and ba.serial_type = 1
);