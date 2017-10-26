*&---------------------------------------------------------------------*
*& Report z_invoice_items_euro
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z_invoice_items_euro.

class lcl_main definition create private.

  public section.
    CLASS-METHODS create
      RETURNING
        value(r_result) TYPE REF TO lcl_main.
    methods run.
  protected section.
  private section.

endclass.

class lcl_main implementation.

  method create.

    create object r_result.

  endmethod.

  method run.
     WRITE: 'Hello World!'.
  endmethod.

endclass.

start-of-selection.

lcl_main=>create( )->run(  ).
