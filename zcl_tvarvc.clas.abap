class ZCL_TVARVC definition
  public
  final
  create public .

*"* public components of class ZCL_TVARVC
*"* do not include other source files here!!!
public section.

  class-methods CLASS_CONSTRUCTOR .
  class-methods GET_SINGLE_VALUE
    importing
      !IC_NAME type RVARI_VNAM
    returning
      value(RC_VALUE) type TVARV_VAL .
  class-methods GET_SELECTION_RANGE
    importing
      !IC_NAME type RVARI_VNAM
    exporting
      !ET_RANGE type RSELOPTION .
protected section.
*"* protected components of class ZCL_BPC_ENTITY_OVERRIDE_MAP
*"* do not include other source files here!!!
private section.
*"* private components of class ZCL_TVARVC
*"* do not include other source files here!!!

  types:
    t_tvarvc TYPE HASHED TABLE OF tvarvc WITH UNIQUE KEY name type numb .

  class-data GTH_TVARVC type T_TVARVC .
  class-data:
    gs_tvarvc_cache LIKE LINE OF gth_tvarvc .

  class-methods _UPDATE_CACHE
    importing
      !IC_NAME type RVARI_VNAM
      !IC_TYPE type RSSCR_KIND
      !IC_NUMB type TVARV_NUMB .
ENDCLASS.



CLASS ZCL_TVARVC IMPLEMENTATION.


METHOD class_constructor.
  SELECT * FROM tvarvc INTO TABLE gth_tvarvc.

  SORT gth_tvarvc.
ENDMETHOD.


METHOD get_selection_range.

  DATA: lt_range TYPE rseloption,
        ls_range LIKE LINE OF lt_range.

  FIELD-SYMBOLS: <fs_tvarvc> LIKE LINE OF gth_tvarvc,
                 <fs_range> LIKE LINE OF lt_range.

  LOOP AT gth_tvarvc ASSIGNING <fs_tvarvc>
    WHERE name = ic_name
          AND type = 'S'.


    APPEND INITIAL LINE TO lt_range ASSIGNING <fs_range>.
    <fs_range>-sign   = <fs_tvarvc>-sign.
    <fs_range>-option = <fs_tvarvc>-opti.
    <fs_range>-low    = <fs_tvarvc>-low.
    <fs_range>-high   = <fs_tvarvc>-high.

  ENDLOOP.

 et_range = lt_range.

ENDMETHOD.


METHOD get_single_value.

* if needed read global company code table and update gs_zcompcode_cache
  _update_cache( ic_name = ic_name ic_type = 'P' ic_numb = 0 ).

  IF gs_tvarvc_cache-name = ic_name AND gs_tvarvc_cache-type = 'P' AND gs_tvarvc_cache-numb EQ 0.
    rc_value = gs_tvarvc_cache-low.
  ELSE.
    rc_value = ''.
  ENDIF.

ENDMETHOD.


METHOD _UPDATE_CACHE.

  IF gs_tvarvc_cache-name NE ic_name or gs_tvarvc_cache-type NE ic_type or gs_tvarvc_cache-numb NE ic_numb.


    READ TABLE gth_tvarvc INTO gs_tvarvc_cache
      WITH TABLE KEY name = ic_name
                     type = ic_type
                     numb = ic_numb.

    IF sy-subrc IS NOT INITIAL.
" clear structure and just populate key fields so we don't have to read table again for same selection
      CLEAR gs_tvarvc_cache.
      gs_tvarvc_cache-name = ic_name.
      gs_tvarvc_cache-type = ic_type.
      gs_tvarvc_cache-numb = ic_numb.
    ENDIF.
  ENDIF.
ENDMETHOD.
ENDCLASS.
