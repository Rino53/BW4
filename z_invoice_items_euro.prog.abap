*&---------------------------------------------------------------------*
*& Report z_invoice_items_euro
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z_invoice_items_euro.

CLASS lcl_main DEFINITION CREATE PRIVATE.

  PUBLIC SECTION.
    CLASS-METHODS create
      RETURNING
        VALUE(r_result) TYPE REF TO lcl_main.
    METHODS run.
  PROTECTED SECTION.
  PRIVATE SECTION.

ENDCLASS.

CLASS lcl_main IMPLEMENTATION.

  METHOD create.

    CREATE OBJECT r_result.

  ENDMETHOD.

  METHOD run.

    DATA: invoices TYPE REF TO zcl_invoice_retrieval.

    invoices = NEW zcl_invoice_retrieval( ).

    DATA(invoice_items) = invoices->get_items_from_db( ).

    cl_salv_table=>factory(
*  EXPORTING
*    list_display   = IF_SALV_C_BOOL_SAP=>FALSE    " ALV Displayed in List Mode
*    r_container    =     " Abstract Container for GUI Controls
*    container_name =
      IMPORTING
        r_salv_table   =    DATA(alv_table)
      CHANGING
        t_table        =  invoice_items ).
    "CATCH cx_salv_msg.    "
    alv_table->display( ).

  ENDMETHOD.

ENDCLASS.

START-OF-SELECTION.

  lcl_main=>create( )->run(  ).
