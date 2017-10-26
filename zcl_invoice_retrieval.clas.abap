CLASS zcl_invoice_retrieval DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPES: ty_table_of_zso_invoice_item TYPE STANDARD TABLE OF zso_invoice_item WITH DEFAULT KEY.
    "! AMDP Market Interface for AMDP
           INTERFACES: if_amdp_marker_hdb.
    "! <p class="shorttext synchronized" lang="en">Read items from DB</p>
    "! Method reads invoice items from database
    "! @parameter lt_result | <p class="shorttext synchronized" lang="en">Table of invoice items</p>
    METHODS get_items_from_db
      RETURNING
        VALUE(lt_result) TYPE ty_table_of_zso_invoice_item.

    METHODS get_items_from_db_amdp
    IMPORTING value(zcurrency_code) type snwd_curr_code
    EXPORTING value(lt_result) TYPE ty_table_of_zso_invoice_item.

  PROTECTED SECTION.
  PRIVATE SECTION.

ENDCLASS.



CLASS zcl_invoice_retrieval IMPLEMENTATION.

  METHOD get_items_from_db.

    SELECT
       snwd_bpa~company_name,
       snwd_so_inv_item~gross_amount,
       snwd_so_inv_item~currency_code,
       snwd_so_inv_head~payment_status
     FROM
      snwd_so_inv_item
      JOIN snwd_so_inv_head ON snwd_so_inv_item~parent_key = snwd_so_inv_head~node_key
      JOIN snwd_bpa ON snwd_so_inv_head~buyer_guid = snwd_bpa~node_key

     WHERE
      snwd_so_inv_item~currency_code = 'EUR'

     ORDER BY  snwd_bpa~company_name

     INTO TABLE @lt_result.

    LOOP AT lt_result ASSIGNING FIELD-SYMBOL(<entry>).

      CASE <entry>-payment_status.
        WHEN 'P'.
          <entry>-payment_status = abap_true.
        WHEN OTHERS.
          <entry>-payment_status = abap_false.
      ENDCASE.


    ENDLOOP.


  ENDMETHOD.

  METHOD get_items_from_db_amdp BY DATABASE PROCEDURE FOR HDB LANGUAGE SQLSCRIPT OPTIONS READ-ONLY USING snwd_bpa snwd_so_inv_item snwd_so_inv_head.

  lt_result =

  SELECT
       so_bpa.company_name as company_name,
       so_item.gross_amount as amount,
       so_item.currency_code as currency_code,
       so_header.payment_status as payment_status
     FROM
      snwd_so_inv_item as so_item
      JOIN snwd_so_inv_head as so_header ON so_item.parent_key = so_header.node_key
      JOIN snwd_bpa as so_bpa ON  so_header.buyer_guid = so_bpa.node_key

     WHERE
      so_item.currency_code = zcurrency_code

     ORDER BY  so_bpa.company_name;


  ENDMETHOD.

ENDCLASS.
