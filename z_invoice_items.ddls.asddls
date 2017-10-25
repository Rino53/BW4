@AbapCatalog.sqlViewName: 'ZINVOICEITEMS'
@AbapCatalog.compiler.compareFilter: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Invoice Items'
define view Z_INVOICE_ITEMS as select from sepm_sddl_so_invoice_item {//SEPM_SDDL_SO_INVOICE_ITEM 

                                                                     sepm_sddl_so_invoice_item.header.buyer.company_name,
                                                                     sepm_sddl_so_invoice_item.currency_code, 
                                                                     sepm_sddl_so_invoice_item.gross_amount,
                                                                     cast(
                                                                     case header.payment_status
                                                                     when 'P' then 'X'
                                                                     else ''
                                                                     end as abap.char( 1 )) as payment_status
                                                                  
                               
}

where currency_code = 'EUR'