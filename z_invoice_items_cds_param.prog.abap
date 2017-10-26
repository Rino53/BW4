*&---------------------------------------------------------------------*
*& Report z_invoice_items_euro
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z_invoice_items_cds_param.

PARAMETERS: zcurr TYPE snwd_curr_code  DEFAULT 'EUR'. "For AMDP and CDS with Parameters Approach

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

*CDS with parameters Approach

    DATA(alv) = cl_salv_gui_table_ida=>create_for_cds_view( 'Z_INVOICE_ITEMS_W_PARAM' ).

*    IF cl_abap_dbfeatures=>use_features(
*              requested_features =
*                   VALUE #( ( cl_abap_dbfeatures=>views_with_parameters ) ) ) EQ abap_true.
    alv->set_view_parameters( VALUE #( ( name = 'zcurr' value = zcurr ) ) ).

*    ENDIF.

    alv->fullscreen( )->display( ).

  ENDMETHOD.

ENDCLASS.

START-OF-SELECTION.

  lcl_main=>create( )->run(  ).
