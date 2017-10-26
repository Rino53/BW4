@AbapCatalog.sqlViewName: 'ZINV_ITEMS_PARAM'
@AbapCatalog.compiler.compareFilter: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Invoice Items CDS with Params'
define view Z_INVOICE_ITEMS_W_PARAM
    with parameters zcurr : snwd_curr_code
as select from sepm_sddl_so_invoice_item {//SEPM_SDDL_SO_INVOICE_ITEM 

                                                                     sepm_sddl_so_invoice_item.header.buyer.company_name,
                                                                     sepm_sddl_so_invoice_item.currency_code, 
                                                                     sepm_sddl_so_invoice_item.gross_amount,
                                                                     @EndUserText: {
                                                                         quickInfo: 'Paid'
                                                                     }
                                                                     cast(
                                                                     
                                                                     case header.payment_status
                                                                     when 'P' then 'X'
                                                                     else ''
                                                                     end as zso_invoice_payment_status) as payment_status                                                                    
                                                                  
                               
}

where currency_code = $parameters.zcurr