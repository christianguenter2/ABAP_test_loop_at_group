*&---------------------------------------------------------------------*
*& Report z_test_loop_at_group
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z_test_loop_at_group.

CLASS controller DEFINITION.

  PUBLIC SECTION.
    METHODS: start.

ENDCLASS.

CLASS controller IMPLEMENTATION.

  METHOD start.

    TYPES: BEGIN OF ty_output,
             head     TYPE string,
             position TYPE string,
           END OF ty_output.

    SELECT FROM t100
           FIELDS *
           WHERE sprsl = @sy-langu
           ORDER BY PRIMARY KEY
           INTO TABLE @DATA(t100_tab)
           UP TO 10 ROWS.

    DATA(output) = REDUCE ty_output( INIT result = VALUE ty_output( )
                                     FOR GROUPS group OF ls_t100 IN t100_tab
                                     INDEX INTO index
                                     GROUP BY ( arbgb = ls_t100-arbgb
                                                msgnr = ls_t100-msgnr )
                                     FOR <ls_t100> IN GROUP group
                                     NEXT result = VALUE #( BASE result
                                                            position = result-position && |\n{ <ls_t100>-text }| ) ). " <=== solution with base
*                                     NEXT result = VALUE #( position = result-position && |\n{ <ls_t100>-text }| ) ). " <=== difference here

    DATA(output2) = REDUCE ty_output( INIT result = VALUE ty_output( )
                                      FOR GROUPS group OF ls_t100 IN t100_tab
                                      INDEX INTO index
                                      GROUP BY ( arbgb = ls_t100-arbgb
                                                 msgnr = ls_t100-msgnr )
                                      FOR <ls_t100> IN GROUP group
                                      NEXT result-position = result-position && |\n{ <ls_t100>-text }| ). " <=== difference here

    " fails no longer:
    ASSERT output = output2.

    cl_demo_output=>write( output-position ).
    cl_demo_output=>write( output2-position ).
    cl_demo_output=>display( ).

  ENDMETHOD.

ENDCLASS.

START-OF-SELECTION.
  NEW controller( )->start( ).
