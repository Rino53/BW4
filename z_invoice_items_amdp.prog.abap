*&---------------------------------------------------------------------*
*& Report z_invoice_items_euro
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z_invoice_items_amdp.

PARAMETERS: zcurr type snwd_curr_code  DEFAULT 'EUR'. "For AMDP Approach

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

*NON-CDS Approach
* DATA: invoices TYPE REF TO zcl_invoice_retrieval.
*
*    invoices = NEW zcl_invoice_retrieval( ).
*
*    DATA(invoice_items) = invoices->get_items_from_db( ).
*
*    cl_salv_table=>factory(
**  EXPORTING
**    list_display   = IF_SALV_C_BOOL_SAP=>FALSE    " ALV Displayed in List Mode
**    r_container    =     " Abstract Container for GUI Controls
**    container_name =
*      IMPORTING
*        r_salv_table   =    DATA(alv_table)
*      CHANGING
*        t_table        =  invoice_items ).
*    "CATCH cx_salv_msg.    "
*    alv_table->display( ).

**CDS Approach
*   cl_salv_gui_table_ida=>create_for_cds_view(
*     EXPORTING
*       iv_cds_view_name               = 'Z_INVOICE_ITEMS'
**       io_gui_container               =
**       io_calc_field_handler          =
**     RECEIVING
**       ro_alv_gui_table_ida           =
*   )->fullscreen( )->display( ).
**     CATCH cx_salv_ida_contract_violation.    "
**     CATCH cx_salv_db_connection.    "
**     CATCH cx_salv_db_table_not_supported.    "
**     CATCH cx_salv_ida_contract_violation.    "
**     CATCH cx_salv_function_not_supported.    "
*
**Alternative call:
**cl_salv_gui_table_ida=>create_for_cds_view( 'Z_INVOICE_ITEMS' )->fullscreen( )->display( ).

**AMDP Approach
DATA: invoices TYPE REF TO zcl_invoice_retrieval.

invoices = NEW zcl_invoice_retrieval( ).

invoices->get_items_from_db_amdp(
  EXPORTING
    zcurrency_code = zcurr
  IMPORTING
   lt_result      = data(invoice_items)
).

    cl_salv_table=>factory(
      IMPORTING
        r_salv_table   =    DATA(alv_table)
      CHANGING
        t_table        =  invoice_items ).
    alv_table->display( ).

  ENDMETHOD.

ENDCLASS.

START-OF-SELECTION.

  lcl_main=>create( )->run(  ).
