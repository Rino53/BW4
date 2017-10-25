class ZCL_TIME definition
  public
  final
  create public .

*"* public components of class ZCL_TIME
*"* do not include other source files here!!!
public section.

  class-methods CALQUATER_FROM_PERIOD
    importing
      !IC_FISCPER type /BI0/OIFISCPER
      !IC_FISCVARNT type /BI0/OIFISCVARNT default 'K4'
    returning
      value(RC_CALQUARTER) type /BI0/OICALQUARTER .
  class-methods FPER_RANGE_TO_SINGLE
    importing
      !IT_RANGE type RSPLF_T_CHARSEL
    exporting
      !ET_RANGE type RSPLF_T_CHARSEL .
  class-methods FPER_TO_PM_DT_LDW
    importing
      !IC_FISCPER type /BI0/OIFISCPER
    returning
      value(RC_DATE) type SY-DATUM .
  class-methods FPER_TO_LAST_DAY
    importing
      !IC_FISCPER type /BI0/OIFISCPER
    returning
      value(RC_DATE) type SY-DATUM .
  class-methods FPER_TO_CM_DT_LDW
    importing
      !IC_FISCPER type /BI0/OIFISCPER
    returning
      value(RC_DATE) type SY-DATUM .
  class-methods FPER_TO_DECPY_DT_LDW
    importing
      !IC_FISCPER type /BI0/OIFISCPER
    returning
      value(RC_DATE) type SY-DATUM .
  class-methods BPC_MNTH_RANGE_TO_ITAB
    importing
      !IC_FROM_MONTH type UJ_DIM_MEMBER
      !IC_TO_MONTH type UJ_DIM_MEMBER
    returning
      value(RT_MONTHS) type UJA_T_DIM_MEMBER .
  class-methods CONVERT_BPC_TIME_TO_BW
    importing
      !IC_BPC_TIME type UJ_DIM_MEMBER
    returning
      value(EC_FISCPER) type /BI0/OIFISCPER .
  class-methods CONVERT_BW_TIME_TO_BPC
    importing
      !IC_FISCPER type /BI0/OIFISCPER
    returning
      value(RC_BPC_TIME) type UJ_DIM_MEMBER .
  class-methods CALQUART1_FROM_CALMONTH
    importing
      !IC_CALMONTH type /BI0/OICALMONTH
    returning
      value(RC_CALQUART1) type /BI0/OICALQUART1 .
  class-methods CALQUATER_FROM_CALMONTH
    importing
      !IC_CALMONTH type /BI0/OICALMONTH
    returning
      value(RC_CALQUARTER) type /BI0/OICALQUARTER .
  class-methods ADD_NO_MONTHS_TO_FISCPER
    importing
      !IN_NO_MONTHS type I
      !IC_FISCPER type ANY
    returning
      value(RC_FISCPER) type /BI0/OIFISCPER .
  class-methods CALMONTH_TO_LASTDAY
    importing
      !IC_CALMONTH type ANY
    returning
      value(RC_DATE) type D .
  class-methods ADD_NO_MONTHS_TO_CALMONTH
    importing
      !IC_CALMONTH type ANY
      !IN_NUM_MONTHS type ANY
    returning
      value(RC_CALMONTH) type /BI0/OICALMONTH .

  class-methods FORMAT_DATE
    importing
      !IC_DATE type DATUM
      !IN_TYPE type I default 1
    returning
      value(RC_DATE_STR) type CHAR30 .
  class-methods GET_WEEKDAY_TEXT
    importing
      !IC_DATE type DATUM
      !IC_TYPE type C default '1'
    returning
      value(RC_WEEKDAY) type STRING .

protected section.
*"* protected components of class ZCL_TIME
*"* do not include other source files here!!!
private section.
*"* private components of class ZCL_TIME
*"* do not include other source files here!!!

 " types T_ZPYCALWEK type /BIC/PZPYCALWEK .

  class-data GC_FP_TO_PM_DT_RC_DATE type SY-DATUM .
  class-data GC_FPER_TO_PM_DT_LDW type /BI0/OIFISCPER .
  class-data GC_FP_TO_CM_DT_RC_DATE type SY-DATUM .
  class-data GC_FPER_TO_CM_DT_LDW type /BI0/OIFISCPER .
  class-data GC_FP_TO_DECPY_DT_RC_DATE type SY-DATUM .
  class-data GC_FPER_TO_DECPY_DT_LDW type /BI0/OIFISCPER .
  class-data GC_FORMAT_DATE_CACHE_IC_DATE type DATUM .
  class-data GC_FORMAT_DATE_CACHE_IN_TYPE type I .
  class-data GC_FORMAT_DATE_CACHE_RC_DATE type STRING .

ENDCLASS.



CLASS ZCL_TIME IMPLEMENTATION.


method ADD_NO_MONTHS_TO_CALMONTH.

  data: lc_date type d.

  CONCATENATE ic_calmonth '01' into lc_date.

  CALL FUNCTION 'Y_MONTH_PLUS_DETERMINE'
    EXPORTING
      months        = in_num_months
      olddate       = lc_date
   IMPORTING
     NEWDATE       = lc_date.

rc_calmonth = lc_date(6).


endmethod.


METHOD add_no_months_to_fiscper.
* Only supports 12 periods.
  DATA: lc_fiscper       TYPE /bi0/oifiscper,
        lb_minus         TYPE boolean,
        ln_abs_no_months TYPE i.

  ln_abs_no_months = abs( in_no_months ).

  IF in_no_months < 0.
    lb_minus = abap_true.
  ENDIF.

  lc_fiscper = ic_fiscper.

  DO ln_abs_no_months TIMES.

    IF lb_minus = abap_false.
      lc_fiscper = lc_fiscper + 1.

      IF lc_fiscper+4 = '013'.
        lc_fiscper(4) = lc_fiscper(4) + 1.
        lc_fiscper+4 = '001'.
      ENDIF.

    ELSE.
      lc_fiscper = lc_fiscper - 1.

      IF lc_fiscper+4 = '000'.
        lc_fiscper(4) = lc_fiscper(4) - 1.
        lc_fiscper+4 = '012'.
      ENDIF.

    ENDIF.
  ENDDO.




  rc_fiscper = lc_fiscper.

ENDMETHOD.


METHOD bpc_mnth_range_to_itab.

  DATA: lc_fiscper_from TYPE /bi0/oifiscper,
        lc_fiscper_to   TYPE /bi0/oifiscper,
        lc_fiscper      TYPE /bi0/oifiscper,
        lc_year         TYPE /bi0/oifiscyear,
        lc_bpc_month    TYPE uj_dim_member,
        lt_bpc_months   TYPE uja_t_dim_member.



  lc_fiscper_from = convert_bpc_time_to_bw( ic_from_month ).
  lc_fiscper_to = convert_bpc_time_to_bw( ic_to_month ).
  lc_fiscper = lc_fiscper_from.

  WHILE lc_fiscper <= lc_fiscper_to.
    lc_bpc_month  = convert_bw_time_to_bpc( lc_fiscper ).
    APPEND lc_bpc_month TO lt_bpc_months.

    IF lc_fiscper+4 = '012'.
      lc_year = lc_fiscper(4) + 1.
      CONCATENATE lc_year '001' INTO lc_fiscper .
    ELSE.
      lc_fiscper = lc_fiscper + 1.
    ENDIF.

  ENDWHILE.

  rt_months = lt_bpc_months.

ENDMETHOD.


METHOD calmonth_to_lastday.

  DATA: lc_date     TYPE rsd_chavl,
        lc_calmonth TYPE rsd_chavl.

  lc_calmonth = ic_calmonth.

  CALL FUNCTION 'RSAU_UPDR_TIME'
    EXPORTING
      i_iobjnm = '0CALMONTH'
      i_per    = '2'
      i_timvl  = lc_calmonth
    IMPORTING
      e_timvl  = lc_date
    EXCEPTIONS
      error    = 1
      OTHERS   = 2.
  IF sy-subrc <> 0.
* Implement suitable error handling here

  ELSE.
    rc_date = lc_date.
  ENDIF.


ENDMETHOD.


METHOD calquart1_from_calmonth.

  DATA: ln_month TYPE i.


  ln_month = ic_calmonth+4(2).

  IF ln_month >= 1 AND ln_month <= 3.
    rc_calquart1 = 1.

  ELSEIF ln_month >= 4 AND ln_month <= 6.
    rc_calquart1 = 2.

  ELSEIF ln_month >= 7 AND ln_month <= 9.
    rc_calquart1 = 3.

  ELSEIF ln_month >= 10 AND ln_month <= 12.
    rc_calquart1 = 4.

  ELSE.
    rc_calquart1 = 0.

  ENDIF.

ENDMETHOD.


METHOD calquater_from_calmonth.

  DATA: ln_month TYPE i,
        lc_quarter(2) TYPE c.


  ln_month = ic_calmonth+4(2).

  IF ln_month >= 1 AND ln_month <= 3.
    CONCATENATE ic_calmonth(4) '1' INTO rc_calquarter.

  ELSEIF ln_month >= 4 AND ln_month <= 6.
    CONCATENATE ic_calmonth(4) '2' INTO rc_calquarter.

  ELSEIF ln_month >= 7 AND ln_month <= 9.
    CONCATENATE ic_calmonth(4) '3' INTO rc_calquarter.

  ELSEIF ln_month >= 10 AND ln_month <= 12.
    CONCATENATE ic_calmonth(4) '4' INTO rc_calquarter.

  ELSE.
    clear rc_calquarter.

  ENDIF.

ENDMETHOD.


METHOD calquater_from_period.

  DATA zcalq TYPE n.

  IF ic_fiscvarnt EQ 'K4' or ic_fiscvarnt EQ 'Z2'.
    IF ic_fiscper+4 LE 3.
      zcalq = 1.
    ELSEIF ic_fiscper+4 LE 6.
      zcalq = 2.
    ELSEIF ic_fiscper+4 LE 9.
      zcalq = 3.
    ELSEIF ic_fiscper+4 LE 16.
      zcalq = 4.
    ENDIF.

    CONCATENATE ic_fiscper(4) zcalq INTO rc_calquarter.
  ELSE.
    rc_calquarter = ''.

  ENDIF.

ENDMETHOD.


method CONVERT_BPC_TIME_TO_BW.
    CASE ic_bpc_time+5(3).
    WHEN 'JAN'.
      CONCATENATE ic_bpc_time(4) '001' INTO ec_fiscper.
    WHEN 'FEB'.
      CONCATENATE ic_bpc_time(4) '002' INTO ec_fiscper.
    WHEN 'MAR'.
      CONCATENATE ic_bpc_time(4) '003' INTO ec_fiscper.
    WHEN 'APR'.
      CONCATENATE ic_bpc_time(4) '004' INTO ec_fiscper.
    WHEN 'MAY'.
      CONCATENATE ic_bpc_time(4) '005' INTO ec_fiscper.
    WHEN 'JUN'.
      CONCATENATE ic_bpc_time(4) '006' INTO ec_fiscper.
    WHEN 'JUL'.
      CONCATENATE ic_bpc_time(4) '007' INTO ec_fiscper.
    WHEN 'AUG'.
      CONCATENATE ic_bpc_time(4) '008' INTO ec_fiscper.
    WHEN 'SEP'.
      CONCATENATE ic_bpc_time(4) '009' INTO ec_fiscper.
    WHEN 'OCT'.
      CONCATENATE ic_bpc_time(4) '010' INTO ec_fiscper.
    WHEN 'NOV'.
      CONCATENATE ic_bpc_time(4) '011' INTO ec_fiscper.
    WHEN 'DEC'.
      CONCATENATE ic_bpc_time(4) '012' INTO ec_fiscper.
    WHEN others.
      ASSERT 1 = 2.
  ENDCASE.
endmethod.


METHOD convert_bw_time_to_bpc.
  CASE ic_fiscper+4(3).
    WHEN '001'.
      CONCATENATE ic_fiscper(4) 'JAN' INTO rc_bpc_time SEPARATED BY '.'.
    WHEN '002'.
      CONCATENATE ic_fiscper(4) 'FEB' INTO rc_bpc_time SEPARATED BY '.'.
    WHEN '003'.
      CONCATENATE ic_fiscper(4) 'MAR' INTO rc_bpc_time SEPARATED BY '.'.
    WHEN '004'.
      CONCATENATE ic_fiscper(4) 'APR' INTO rc_bpc_time SEPARATED BY '.'.
    WHEN '005'.
      CONCATENATE ic_fiscper(4) 'MAY' INTO rc_bpc_time SEPARATED BY '.'.
    WHEN '006'.
      CONCATENATE ic_fiscper(4) 'JUN' INTO rc_bpc_time SEPARATED BY '.'.
    WHEN '007'.
      CONCATENATE ic_fiscper(4) 'JUL' INTO rc_bpc_time SEPARATED BY '.'.
    WHEN '008'.
      CONCATENATE ic_fiscper(4) 'AUG' INTO rc_bpc_time SEPARATED BY '.'.
    WHEN '009'.
      CONCATENATE ic_fiscper(4) 'SEP' INTO rc_bpc_time SEPARATED BY '.'.
    WHEN '010'.
      CONCATENATE ic_fiscper(4) 'OCT' INTO rc_bpc_time SEPARATED BY '.'.
    WHEN '011'.
      CONCATENATE ic_fiscper(4) 'NOV' INTO rc_bpc_time SEPARATED BY '.'.
    WHEN '012'.
      CONCATENATE ic_fiscper(4) 'DEC' INTO rc_bpc_time SEPARATED BY '.'.
    WHEN OTHERS.
      ASSERT 1 = 2.
  ENDCASE.
ENDMETHOD.


  METHOD FORMAT_DATE.
* returns date in various formats
* IC_type 01 = 21st December 2015
* IC_type 02 = Monday 21st December 2015
* IC_type 03 = Monday (21-12-2015)

    DATA: ln_month       TYPE i,
          lc_lmonth      TYPE fcltx,
          ln_day         TYPE i,
          lc_day(2)      TYPE c,
          lc_daynum(10)  TYPE c,
          lc_weekday(10) TYPE c,
          lc_date1(12)   TYPE c.


    IF gc_format_date_cache_ic_date <> ic_date OR gc_format_date_cache_in_type <> in_type.


      ln_month = ic_date+4(2).

      ln_day = ic_date+6(2).
      lc_day = ln_day. " remove leading zero's

      CASE ln_day.
        WHEN  1 OR 21 OR  31.
          CONCATENATE lc_day 'st' INTO lc_daynum.

        WHEN 2 OR  22.
          CONCATENATE lc_day 'nd' INTO lc_daynum.

        WHEN 3 OR 23.
          CONCATENATE lc_day 'rd' INTO lc_daynum.

        WHEN OTHERS.
          CONCATENATE lc_day 'th' INTO lc_daynum.

      ENDCASE.


* Get full month name
      SELECT SINGLE ltx FROM t247
        INTO lc_lmonth
        WHERE spras = sy-langu
        AND mnr = ln_month.

* IC_type 1 = 21st December 2015
* IC_type 2 = Monday 21st December 2015
* IC_type 3 = Monday (21-12-2015)
      CASE in_type.
        WHEN 1. " 21st December 2015

          IF ln_month IS NOT INITIAL.
            CONCATENATE lc_daynum lc_lmonth ic_date(4) INTO rc_date_str SEPARATED BY space.
          ELSE.
            rc_date_str = ic_date.
          ENDIF.

        WHEN 2. " Monday 21st December 2015

          IF ln_month IS NOT INITIAL.
            lc_weekday = zcl_time=>get_weekday_text( ic_date = ic_date
                                                     ic_type = '1' ).

            CONCATENATE lc_weekday lc_daynum lc_lmonth ic_date(4) INTO rc_date_str SEPARATED BY space.
          ELSE.
            rc_date_str = ic_date.
          ENDIF.

        WHEN 3. "  Monday (21-12-2015)

          CONCATENATE '(' ic_date+6(2) '-' ic_date+4(2) '-' ic_date(4) ')' INTO lc_date1.

          lc_weekday = zcl_time=>get_weekday_text( ic_date = ic_date
                                                   ic_type = '1' ).

          CONCATENATE lc_weekday lc_date1 INTO rc_date_str SEPARATED BY space.

      ENDCASE.


    ELSE.
      rc_date_str = gc_format_date_cache_rc_date.
    ENDIF.
  ENDMETHOD.


  METHOD fper_range_to_single.

* Note only equals and between selections are supported.
*      Only inclusions are supported, no check is made.

    DATA: ls_range   LIKE LINE OF it_range,
          lc_fiscper TYPE /bi0/oifiscper.

    LOOP AT it_range INTO ls_range
      WHERE iobjnm = '0FISCPER'.

      IF ls_range-opt = 'EQ'.
        APPEND ls_range TO et_range.
      ELSEIF ls_range-opt = 'BT'.

        lc_fiscper = ls_range-low.

        WHILE lc_fiscper <= ls_range-high.

          ls_range-low = lc_fiscper.
          ls_range-opt = 'EQ'.

          APPEND ls_range TO et_range.

* Get next period
          lc_fiscper = zcl_time=>add_no_months_to_fiscper( EXPORTING in_no_months = 1 ic_fiscper = lc_fiscper ).

        ENDWHILE.

      ENDIF.


    ENDLOOP.

  ENDMETHOD.


method FPER_TO_CM_DT_LDW.

  DATA: zfiscyear TYPE /bi0/oifiscyear,
        zfiscper  TYPE /bi0/oifiscper3,
        zdate     TYPE sy-datum.

  IF ic_fiscper = gc_fper_to_cm_dt_ldw.
    rc_date = gc_fp_to_cm_dt_rc_date.
  ELSE.

    zfiscyear = ic_fiscper(4).
    zfiscper = ic_fiscper+4(3).

* Tidy up fscal period
    IF zfiscper = '000'.
      zfiscyear = zfiscyear - 1.
      zfiscper = '012'.
    ELSEIF zfiscper BETWEEN '013' AND '016'.
      zfiscyear = zfiscyear.
      zfiscper = '012'.
    ENDIF.

*--------------------------------------------------------*
* Last day of current month                             *
*--------------------------------------------------------*
      CALL FUNCTION 'LAST_DAY_IN_PERIOD_GET'
      EXPORTING
        i_gjahr = zfiscyear
*         I_MONMIT
        i_periv = 'K4'
        i_poper = zfiscper
      IMPORTING
        e_date = zdate
      EXCEPTIONS
        input_false          = 1
        t009_notfound        = 2
        t009b_notfound       = 3
        OTHERS               = 4.

      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*        RAISE EXCEPTION TYPE cx_rsrout_abort.
      ENDIF.


      CALL FUNCTION 'DATE_CONVERT_TO_FACTORYDATE'
        EXPORTING
          correct_option               = '-'
          date                         = zdate
          factory_calendar_id          = 'GB'
        IMPORTING
          date                         = zdate
        EXCEPTIONS
          calendar_buffer_not_loadable = 1
          correct_option_invalid       = 2
          date_after_range             = 3
          date_before_range            = 4
          date_invalid                 = 5
          factory_calendar_not_found   = 6
          OTHERS                       = 7.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*        RAISE EXCEPTION TYPE cx_rsrout_abort.

      ENDIF.



* Update static cache varibles
    gc_fper_to_cm_dt_ldw = ic_fiscper.
    gc_fp_to_cm_dt_rc_date = zdate.

    rc_date = zdate.
  ENDIF.
endmethod.


METHOD fper_to_decpy_dt_ldw.

  DATA: zfiscyear TYPE /bi0/oifiscyear,
        zfiscper  TYPE /bi0/oifiscper3,
        zdate     TYPE sy-datum.

  IF ic_fiscper = gc_fper_to_decpy_dt_ldw.
    rc_date = gc_fp_to_decpy_dt_rc_date.
  ELSE.

    zfiscyear = ic_fiscper(4).
    zfiscper = ic_fiscper+4(3).

*--------------------------------------------------------*
* Last day of December in prior year                     *
*--------------------------------------------------------*

      zfiscper = '012'.
      zfiscyear =  zfiscyear - 1.

      CALL FUNCTION 'LAST_DAY_IN_PERIOD_GET'
      EXPORTING
        i_gjahr = zfiscyear
*         I_MONMIT
        i_periv = 'K4'
        i_poper = zfiscper
      IMPORTING
        e_date = zdate
      EXCEPTIONS
        input_false          = 1
        t009_notfound        = 2
        t009b_notfound       = 3
        OTHERS               = 4.

      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*       RAISE EXCEPTION TYPE cx_rsrout_abort.
      ENDIF.


      CALL FUNCTION 'DATE_CONVERT_TO_FACTORYDATE'
        EXPORTING
          correct_option      = '-'
          date                = zdate
          factory_calendar_id = 'GB'
        IMPORTING
          date                = zdate
        EXCEPTIONS
          calendar_buffer_not_loadable = 1
          correct_option_invalid       = 2
          date_after_range             = 3
          date_before_range            = 4
          date_invalid                 = 5
          factory_calendar_not_found   = 6
          OTHERS                       = 7.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*        RAISE EXCEPTION TYPE cx_rsrout_abort.
      ENDIF.

* Update static cache varibles
    gc_fper_to_decpy_dt_ldw = ic_fiscper.
    gc_fp_to_decpy_dt_rc_date = zdate.

    rc_date = zdate.
  ENDIF.
ENDMETHOD.


method FPER_TO_LAST_DAY.

  DATA: zfiscyear TYPE /bi0/oifiscyear,
        zfiscper  TYPE /bi0/oifiscper3,
        zdate     TYPE sy-datum.

  IF ic_fiscper = gc_fper_to_cm_dt_ldw.
    rc_date = gc_fp_to_cm_dt_rc_date.
  ELSE.

    zfiscyear = ic_fiscper(4).
    zfiscper = ic_fiscper+4(3).

* Tidy up fscal period
    IF zfiscper = '000'.
      zfiscyear = zfiscyear - 1.
      zfiscper = '012'.
    ELSEIF zfiscper BETWEEN '013' AND '016'.
      zfiscyear = zfiscyear.
      zfiscper = '012'.
    ENDIF.

*--------------------------------------------------------*
* Last day of current month                             *
*--------------------------------------------------------*
      CALL FUNCTION 'LAST_DAY_IN_PERIOD_GET'
      EXPORTING
        i_gjahr = zfiscyear
*         I_MONMIT
        i_periv = 'K4'
        i_poper = zfiscper
      IMPORTING
        e_date = zdate
      EXCEPTIONS
        input_false          = 1
        t009_notfound        = 2
        t009b_notfound       = 3
        OTHERS               = 4.

      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*        RAISE EXCEPTION TYPE cx_rsrout_abort.
      ENDIF.


* Update static cache varibles
    gc_fper_to_cm_dt_ldw = ic_fiscper.
    gc_fp_to_cm_dt_rc_date = zdate.

    rc_date = zdate.
  ENDIF.
endmethod.


METHOD fper_to_pm_dt_ldw.

  DATA: zfiscyear TYPE /bi0/oifiscyear,
        zfiscper  TYPE /bi0/oifiscper3,
        zdate     TYPE sy-datum.

  IF ic_fiscper = gc_fper_to_pm_dt_ldw.
    rc_date = gc_fp_to_pm_dt_rc_date.
  ELSE.

    zfiscyear = ic_fiscper(4).
    zfiscper = ic_fiscper+4(3).

* Tidy up fscal period
    IF zfiscper = '000'.
      zfiscyear = zfiscyear - 1.
      zfiscper = '012'.
    ELSEIF zfiscper BETWEEN '013' AND '016'.
      zfiscyear = zfiscyear.
      zfiscper = '012'.
    ENDIF.

*--------------------------------------------------------*
* Last day of previous month                             *
*--------------------------------------------------------*
    IF zfiscper = '001'.
      zfiscper = '012'.
      zfiscyear = zfiscyear - 1.
    ELSE.
      zfiscper = zfiscper - 1.
      zfiscyear = zfiscyear.
    ENDIF.


    CALL FUNCTION 'LAST_DAY_IN_PERIOD_GET'
    EXPORTING
      i_gjahr = zfiscyear
*         I_MONMIT
      i_periv = 'K4'
      i_poper = zfiscper
    IMPORTING
      e_date = zdate
    EXCEPTIONS
      input_false          = 1
      t009_notfound        = 2
      t009b_notfound       = 3
      OTHERS               = 4.

    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*      RAISE EXCEPTION TYPE cx_rsrout_abort.
    ENDIF.


    CALL FUNCTION 'DATE_CONVERT_TO_FACTORYDATE'
      EXPORTING
        correct_option               = '-'
        date                         = zdate
        factory_calendar_id          = 'GB'
      IMPORTING
        date                         = zdate
      EXCEPTIONS
        calendar_buffer_not_loadable = 1
        correct_option_invalid       = 2
        date_after_range             = 3
        date_before_range            = 4
        date_invalid                 = 5
        factory_calendar_not_found   = 6
        OTHERS                       = 7.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*     RAISE EXCEPTION TYPE cx_rsrout_abort.
    ENDIF.

* Update static cache varibles
    gc_fper_to_pm_dt_ldw = ic_fiscper.
    gc_fp_to_pm_dt_rc_date = zdate.

    rc_date = zdate.
  ENDIF.
ENDMETHOD.

  METHOD get_weekday_text.

    DATA: ln_day TYPE scal-indicator.

    CALL FUNCTION 'DATE_COMPUTE_DAY'
      EXPORTING
        date   = ic_date
      IMPORTING
        day    = ln_day
      EXCEPTIONS
        OTHERS = 8.

    CASE ln_day.
      WHEN '1'.
        rc_weekday = 'Monday'.
      WHEN '2'.
        rc_weekday = 'Tuesday'.
      WHEN '3'.
        rc_weekday = 'Wednesday'.
      WHEN '4'.
        rc_weekday = 'Thursday'.
      WHEN '5'.
        rc_weekday = 'Friday'.
      WHEN '6'.
        rc_weekday = 'Saturday'.
      WHEN '7'.
        rc_weekday = 'Sunday'.
      WHEN OTHERS.
        rc_weekday = 'invalid'.
    ENDCASE.

    CASE ic_type.
      When '1'. "EG: Monday

      WHEN '2'. "EG: Mon
        rc_weekday = rc_weekday(3).
      WHEN '3'. "EG: MON
        rc_weekday = rc_weekday(3).
        TRANSLATE rc_weekday TO UPPER CASE.
    ENDCASE.
  ENDMETHOD.


ENDCLASS.
