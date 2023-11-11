//////////////////////////////////////////////////////////////////////
// NOTE: Use the `#define` settings below to customize this keymap! //
// You can override them here instead of modifying them down there. //
// /* EXAMPLE: */  #define EMOJI_HAIR_STYLE_PRESET 3 // curly_hair  //
//////////////////////////////////////////////////////////////////////
//
// Sunaku's Keymap v29 featuring the Engrammer layout with Miryoku
// - https://github.com/sunaku/glove80-keymaps
//
//////////////////////////////////////////////////////////////////////

behaviors {

    //////////////////////////////////////////////////////////////////////////
    //
    // Miryoku layers and home row mods (ported from my QMK endgame)
    // - https://sunaku.github.io/home-row-mods.html#porting-to-zmk
    // - https://github.com/urob/zmk-config#timeless-homerow-mods
    //
    //////////////////////////////////////////////////////////////////////////

    //
    // HOMEY_HOLDING_TYPE defines the flavor of ZMK hold-tap behavior to use
    // for the pinky, ring, and middle fingers (which are assigned to Super,
    // Alt, and Ctrl respectively in the Miryoku system) on home row keys.
    //
    #ifndef HOMEY_HOLDING_TYPE
    #define HOMEY_HOLDING_TYPE "tap-preferred"
    #endif

    //
    // HOMEY_HOLDING_TIME defines how long you need to hold (milliseconds)
    // home row mod keys in order to send their modifiers to the computer
    // (i.e. "register" them) for mod-click mouse usage (e.g. Ctrl-Click).
    //
    #ifndef HOMEY_HOLDING_TIME
    #define HOMEY_HOLDING_TIME 270 // TAPPING_TERM + ALLOW_CROSSOVER_AFTER
    #endif

    //
    // HOMEY_STREAK_DECAY defines how long you need to wait (milliseconds)
    // after typing before you can use home row mods again.  It prevents
    // unintended activation of home row mods when you're actively typing.
    //
    #ifndef HOMEY_STREAK_DECAY
    #define HOMEY_STREAK_DECAY 170 // global-quick-tap-ms
    #endif

    //
    // HOMEY_REPEAT_DECAY defines how much time you have left (milliseconds)
    // after tapping a key to hold it again in order to make it auto-repeat.
    //
    #ifndef HOMEY_REPEAT_DECAY
    #define HOMEY_REPEAT_DECAY 300 // "tap then hold" for key auto-repeat
    #endif

    //
    // SHIFT_HOLDING_TYPE defines the flavor of ZMK hold-tap behavior to use
    // for index fingers (which Miryoku assigns to Shift) on home row keys.
    //
    // NOTE: The "tap-preferred" flavor of ZMK hold-tap for index finger keys
    // allows faster activation of the Shift modifier (without having to wait
    // for the modified key to be released as the "balanced" flavor requires).
    // Typing streaks and the `hold-trigger-on-release` setting are disabled
    // for the index fingers so as not to hinder their speed and dexterity.
    //
    #ifndef SHIFT_HOLDING_TYPE
    #define SHIFT_HOLDING_TYPE "tap-preferred"
    #endif

    //
    // SHIFT_HOLDING_TIME defines how long you need to hold (milliseconds)
    // index finger keys in order to send their modifiers to the computer
    // (i.e. "register" them) for mod-click mouse usage (e.g. Shift-Click).
    //
    // CAUTION: You'll need to perform inward rolls from pinky->ring->middle
    // fingers toward the index fingers when activating multiple modifiers
    // because `hold-trigger-on-release` is disabled for the index fingers.
    // Otherwise, you may be surprised that the index fingers' modifier is
    // sent immediately without the rest of your multi-mod chord when you
    // perform outward rolls from your index fingers toward your pinkies.
    //
    #ifndef SHIFT_HOLDING_TIME
    #define SHIFT_HOLDING_TIME 170
    #endif

    //
    // SHIFT_STREAK_DECAY defines how long you need to wait (milliseconds)
    // after typing before you can use home row mods again.  It prevents
    // unintended activation of home row mods when you're actively typing.
    //
    #ifndef SHIFT_STREAK_DECAY
    #define SHIFT_STREAK_DECAY 70 // global-quick-tap-ms
    #endif

    //
    // SHIFT_REPEAT_DECAY defines how much time you have left (milliseconds)
    // after tapping a key to hold it again in order to make it auto-repeat.
    //
    #ifndef SHIFT_REPEAT_DECAY
    #define SHIFT_REPEAT_DECAY 300 // "tap then hold" for key auto-repeat
    #endif

    //
    // THUMB_HOLDING_TYPE defines the flavor of ZMK hold-tap behavior to use
    // for the thumbs (which are assigned to 6 layers in the Miryoku system).
    //
    // NOTE: The "balanced" flavor of ZMK hold-tap provides instant modifier
    // activation for the symbol layer (if the tapped symbol key is released
    // while the thumb layer key is still held down) for quicker programming.
    //
    #ifndef THUMB_HOLDING_TYPE
    #define THUMB_HOLDING_TYPE "balanced"
    #endif

    //
    // THUMB_HOLDING_TIME defines how long you need to hold (milliseconds)
    // a thumb key to activate a layer.  Shorter holds are treated as taps.
    //
    #ifndef THUMB_HOLDING_TIME
    #define THUMB_HOLDING_TIME 200
    #endif

    //
    // THUMB_REPEAT_DECAY defines how much time you have left (milliseconds)
    // after tapping a key to hold it again in order to make it auto-repeat.
    //
    #ifndef THUMB_REPEAT_DECAY
    #define THUMB_REPEAT_DECAY 300 // "tap then hold" for key auto-repeat
    #endif

    //
    // SPACE_HOLDING_TIME defines how long you need to hold (milliseconds)
    // the space thumb key to activate.  Shorter holds are treated as taps.
    //
    #ifndef SPACE_HOLDING_TIME
    #define SPACE_HOLDING_TIME 170
    #endif

    //
    // SPACE_REPEAT_DECAY defines how much time you have left (milliseconds)
    // after tapping a key to hold it again in order to make it auto-repeat.
    //
    #ifndef SPACE_REPEAT_DECAY
    #define SPACE_REPEAT_DECAY 200 // "tap then hold" for key auto-repeat
    #endif

    //
    // Glove80 key positions index for positional hold-tap
    // - https://discord.com/channels/877392805654306816/937645688244826154/1066713913351221248
    // - https://media.discordapp.net/attachments/937645688244826154/1066713913133121556/image.png
    //
    // |------------------------|------------------------|
    // | LEFT_HAND_KEYS         |        RIGHT_HAND_KEYS |
    // |                        |                        |
    // |  0  1  2  3  4         |          5  6  7  8  9 |
    // | 10 11 12 13 14 15      |      16 17 18 19 20 21 |
    // | 22 23 24 25 26 27      |      28 29 30 31 32 33 |
    // | 34 35 36 37 38 39      |      40 41 42 43 44 45 |
    // | 46 47 48 49 50 51      |      58 59 60 61 62 63 |
    // | 64 65 66 67 68         |         75 76 77 78 79 |
    // |                69 52   |   57 74                |
    // |                 70 53  |  56 73                 |
    // |                  71 54 | 55 72                  |
    // |------------------------|------------------------|
    //
    #define LEFT_HAND_KEYS      \
          0  1  2  3  4         \
         10 11 12 13 14 15      \
         22 23 24 25 26 27      \
         34 35 36 37 38 39      \
         46 47 48 49 50 51      \
         64 65 66 67 68
    #define RIGHT_HAND_KEYS     \
                                           5  6  7  8  9 \
                                       16 17 18 19 20 21 \
                                       28 29 30 31 32 33 \
                                       40 41 42 43 44 45 \
                                       58 59 60 61 62 63 \
                                          75 76 77 78 79
    #define THUMB_KEYS          \
                        69 52       57 74                \
                         70 53     56 73                 \
                          71 54   55 72

    // vtr custom

    // Home row mod-tap keys for all except index fingers
    //
    homey_left: miryoku_home_row_mods_left_hand {
        compatible = "zmk,behavior-hold-tap";
        label = "HOME_ROW_MODS_LEFT_HAND";
        flavor = HOMEY_HOLDING_TYPE;
        hold-trigger-key-positions = <RIGHT_HAND_KEYS THUMB_KEYS>;
        hold-trigger-on-release; // wait for other home row mods
        tapping-term-ms = <HOMEY_HOLDING_TIME>;
        quick-tap-ms = <HOMEY_REPEAT_DECAY>;
        require-prior-idle-ms = <HOMEY_STREAK_DECAY>;
        #binding-cells = <2>;
        bindings = <&kp>, <&kp>;
    };
    homey_right: miryoku_home_row_mods_right_hand {
        compatible = "zmk,behavior-hold-tap";
        label = "HOME_ROW_MODS_RIGHT_HAND";
        flavor = HOMEY_HOLDING_TYPE;
        hold-trigger-key-positions = <LEFT_HAND_KEYS THUMB_KEYS>;
        hold-trigger-on-release; // wait for other home row mods
        tapping-term-ms = <HOMEY_HOLDING_TIME>;
        quick-tap-ms = <HOMEY_REPEAT_DECAY>;
        require-prior-idle-ms = <HOMEY_STREAK_DECAY>;
        #binding-cells = <2>;
        bindings = <&kp>, <&kp>;
    };

    //
    // Special home row mod-tap keys for the index fingers
    //
    shift_left: miryoku_home_row_mods_left_shift_shift {
        compatible = "zmk,behavior-hold-tap";
        label = "HOME_ROW_MODS_LEFT_SHIFT_SHIFT";
        flavor = SHIFT_HOLDING_TYPE;
        hold-trigger-key-positions = <RIGHT_HAND_KEYS THUMB_KEYS>;
        //hold-trigger-on-release; // don't wait for other mods
        tapping-term-ms = <SHIFT_HOLDING_TIME>;
        quick-tap-ms = <SHIFT_REPEAT_DECAY>;
        require-prior-idle-ms = <SHIFT_STREAK_DECAY>;
        #binding-cells = <2>;
        bindings = <&kp>, <&kp>;
    };
    shift_right: miryoku_home_row_mods_right_shift_shift {
        compatible = "zmk,behavior-hold-tap";
        label = "HOME_ROW_MODS_RIGHT_SHIFT_SHIFT";
        flavor = SHIFT_HOLDING_TYPE;
        hold-trigger-key-positions = <LEFT_HAND_KEYS THUMB_KEYS>;
        //hold-trigger-on-release; // don't wait for other mods
        tapping-term-ms = <SHIFT_HOLDING_TIME>;
        quick-tap-ms = <SHIFT_REPEAT_DECAY>;
        require-prior-idle-ms = <SHIFT_STREAK_DECAY>;
        #binding-cells = <2>;
        bindings = <&kp>, <&kp>;
    };

    //
    // Thumb cluster hold-tap keys for Miryoku layers
    //
    thumb: miryoku_thumb_layer {
        compatible = "zmk,behavior-hold-tap";
        label = "MIRYOKU_THUMB_LAYER";
        flavor = THUMB_HOLDING_TYPE;
        tapping-term-ms = <THUMB_HOLDING_TIME>;
        quick-tap-ms = <THUMB_REPEAT_DECAY>; // enable repeat
        //global-quick-tap; // no typing streak
        //retro-tap; // don't allow slow (hold-like) taps
        #binding-cells = <2>;
        bindings = <&mo>, <&kp>;
    };
    space: miryoku_thumb_layer_spacebar {
        compatible = "zmk,behavior-hold-tap";
        label = "MIRYOKU_THUMB_LAYER_SPACEBAR";
        flavor = THUMB_HOLDING_TYPE;
        tapping-term-ms = <SPACE_HOLDING_TIME>;
        quick-tap-ms = <SPACE_REPEAT_DECAY>; // enable repeat
        //global-quick-tap; // no typing streak
        retro-tap; // allow slow (hold-like) taps
        #binding-cells = <2>;
        bindings = <&mo>, <&kp>;
    };

    //////////////////////////////////////////////////////////////////////////
    //
    // Custom shifted pairs
    //
    //////////////////////////////////////////////////////////////////////////

    //
    // Shift + CapsWord = CapsLock
    //
    cappy: capsword_and_capslock {
        compatible = "zmk,behavior-mod-morph";
        label = "CAPSWORD_AND_CAPSLOCK";
        #binding-cells = <0>;
        bindings = <&caps_word>, <&kp CAPSLOCK>;
        mods = <(MOD_LSFT|MOD_RSFT)>;
    };

    //////////////////////////////////////////////////////////////////////////
    //
    // ZMK global overrides
    //
    //////////////////////////////////////////////////////////////////////////

    //
    // CapsWord - ported from Pascal Getreuer's extension for QMK
    // - https://zmk.dev/docs/behaviors/caps-word
    // - https://getreuer.info/posts/keyboards/caps-word/index.html
    //
    behavior_caps_word {
        continue-list = <
            UNDERSCORE MINUS
            BACKSPACE DELETE
            N1 N2 N3 N4 N5 N6 N7 N8 N9 N0
        >;
    };

};

macros {

    // vtr custom
    ZMK_MACRO(alttab,
        bindings =  <&macro_press &kp LALT> // leave GUI down to keep menu up
                , <&macro_tap &kp TAB> // combines with shift fine
                , <&macro_tap &sk LALT> // this will release GUI after a timeout
                , <&macro_release &kp LALT> // now release the previous hold
                        ;
        )
    ZMK_MACRO(winleft,
        bindings =  <&macro_press &kp LGUI> // leave GUI down to keep menu up
                , <&macro_tap &kp LEFT> // combines with shift fine
                , <&macro_tap &sk LGUI> // this will release GUI after a timeout
                , <&macro_release &kp LGUI> // now release the previous hold
                        ;
        )
    ZMK_MACRO(winright,
        bindings =  <&macro_press &kp LGUI> // leave GUI down to keep menu up
                , <&macro_tap &kp RIGHT> // combines with shift fine
                , <&macro_tap &sk LGUI> // this will release GUI after a timeout
                , <&macro_release &kp LGUI> // now release the previous hold
                        ;
        )
    ZMK_MACRO(winup,
        bindings =  <&macro_press &kp LGUI> // leave GUI down to keep menu up
                , <&macro_tap &kp UP> // combines with shift fine
                , <&macro_tap &sk LGUI> // this will release GUI after a timeout
                , <&macro_release &kp LGUI> // now release the previous hold
                        ;
        )
    ZMK_MACRO(windown,
        bindings =  <&macro_press &kp LGUI> // leave GUI down to keep menu up
                , <&macro_tap &kp DOWN> // combines with shift fine
                , <&macro_tap &sk LGUI> // this will release GUI after a timeout
                , <&macro_release &kp LGUI> // now release the previous hold
                        ;
        )
    //////////////////////////////////////////////////////////////////////////
    //
    // Approximation of Pascal Getreuer's Select Word macro from QMK
    // - https://getreuer.info/posts/keyboards/select-word/index.html
    //
    //////////////////////////////////////////////////////////////////////////
    //
    // SELECT_WORD_DELAY defines how long the macro waits (milliseconds)
    // after moving the cursor before it selects a word.  A larger delay
    // may allow the macro to move to the next word upon each invocation.
    //
    #ifndef SELECT_WORD_DELAY
    #define SELECT_WORD_DELAY 1
    #endif

    ZMK_MACRO(select_none,
        wait-ms = <SELECT_WORD_DELAY>;
        tap-ms = <SELECT_WORD_DELAY>;
        bindings = <&kp DOWN &kp UP &kp RIGHT &kp LEFT>;
    )

    //
    // select a word (jumps to next word upon each successive invocation)
    //
    select_word: select_word {
        compatible = "zmk,behavior-mod-morph";
        label = "SELECT_WORD";
        #binding-cells = <0>;
        bindings = <&select_word_right>, <&select_word_left>;
        mods = <(MOD_LSFT|MOD_RSFT)>;
    };
    ZMK_MACRO(select_word_right,
        wait-ms = <SELECT_WORD_DELAY>;
        tap-ms = <SELECT_WORD_DELAY>;
        bindings = <&kp LC(RIGHT) &kp LC(LEFT) &kp LC(LS(RIGHT))>;
    )
    ZMK_MACRO(select_word_left,
        wait-ms = <SELECT_WORD_DELAY>;
        tap-ms = <SELECT_WORD_DELAY>;
        bindings = <&kp LC(LEFT) &kp LC(RIGHT) &kp LC(LS(LEFT))>;
    )

    //
    // extend current selection by one word
    //
    extend_word: extend_word {
        compatible = "zmk,behavior-mod-morph";
        label = "EXTEND_WORD";
        #binding-cells = <0>;
        bindings = <&extend_word_right>, <&extend_word_left>;
        mods = <(MOD_LSFT|MOD_RSFT)>;
    };
    ZMK_MACRO(extend_word_right,
        wait-ms = <SELECT_WORD_DELAY>;
        tap-ms = <SELECT_WORD_DELAY>;
        bindings = <&kp LC(LS(RIGHT))>;
    )
    ZMK_MACRO(extend_word_left,
        wait-ms = <SELECT_WORD_DELAY>;
        tap-ms = <SELECT_WORD_DELAY>;
        bindings = <&kp LC(LS(LEFT))>;
    )

    //
    // select current line
    //
    select_line: select_line {
        compatible = "zmk,behavior-mod-morph";
        label = "SELECT_LINE";
        #binding-cells = <0>;
        bindings = <&select_line_right>, <&select_line_left>;
        mods = <(MOD_LSFT|MOD_RSFT)>;
    };
    ZMK_MACRO(select_line_right,
        wait-ms = <SELECT_WORD_DELAY>;
        tap-ms = <SELECT_WORD_DELAY>;
        bindings = <&kp HOME &kp LS(END)>;
    )
    ZMK_MACRO(select_line_left,
        wait-ms = <SELECT_WORD_DELAY>;
        tap-ms = <SELECT_WORD_DELAY>;
        bindings = <&kp END &kp LS(HOME)>;
    )

    //
    // extend current selection by one line
    //
    extend_line: extend_line {
        compatible = "zmk,behavior-mod-morph";
        label = "EXTEND_LINE";
        #binding-cells = <0>;
        bindings = <&extend_line_right>, <&extend_line_left>;
        mods = <(MOD_LSFT|MOD_RSFT)>;
    };
    ZMK_MACRO(extend_line_right,
        wait-ms = <SELECT_WORD_DELAY>;
        tap-ms = <SELECT_WORD_DELAY>;
        bindings = <&kp LS(DOWN) &kp LS(END)>;
    )
    ZMK_MACRO(extend_line_left,
        wait-ms = <SELECT_WORD_DELAY>;
        tap-ms = <SELECT_WORD_DELAY>;
        bindings = <&kp LS(UP) &kp LS(HOME)>;
    )

    //////////////////////////////////////////////////////////////////////////
    //
    // World layer - international characters
    //
    //////////////////////////////////////////////////////////////////////////

    //
    // UNICODE_TARGET_OS defines which operating system you're targeting
    // for use with the UNICODE() macro.  This is needed because each OS
    // has different shortcuts for typing Unicode characters as hexcodes.
    //
    // NOTE: You may need to enable Unicode hexadecimal input in your OS:
    // - https://ladedu.com/how-to-enter-unicode-characters-on-a-mac/
    // - https://unicode-explorer.com/articles/how-to-type-unicode-characters-in-linux
    // - https://unicode-explorer.com/articles/how-to-type-unicode-characters-in-windows
    //
    #ifndef UNICODE_TARGET_OS
    #define UNICODE_TARGET_OS 1 // linux
    //#define UNICODE_TARGET_OS 2 // macos
    //#define UNICODE_TARGET_OS 3 // windows
    #endif

    //
    // UNICODE_TAP_DELAY defines how long the macro waits (milliseconds)
    // between keystrokes while inputting the Unicode codepoint shortcut.
    //
    #ifndef UNICODE_TAP_DELAY
    #define UNICODE_TAP_DELAY 1
    #endif

    //
    // UNICODE_SEQ_DELAY defines how long the macro waits (milliseconds)
    // between emitting Unicode codepoints in multi-codepoint characters.
    //
    #ifndef UNICODE_SEQ_DELAY
    #define UNICODE_SEQ_DELAY 10
    #endif

    #define UNICODE(name, ...) \
        ZMK_MACRO(name, \
            wait-ms = <UNICODE_TAP_DELAY>; \
            tap-ms = <UNICODE_TAP_DELAY>; \
            bindings = __VA_ARGS__; \
        )

    //
    // NOTE: edit the emoji.yaml file and run `rake` to generate this:
    //

    //
    // codepoints
    //

      /* ° */ UNICODE(world_degree_sign,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp B &kp N0 &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N0 &kp N0 &kp B &kp N0>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp B &kp KP_N0>, <&macro_release &kp LALT>
        #endif
      )

      /* § */ UNICODE(world_section_sign,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp A &kp N7 &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N0 &kp N0 &kp A &kp N7>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp A &kp KP_N7>, <&macro_release &kp LALT>
        #endif
      )

      /* ¶ */ UNICODE(world_paragraph_sign,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp B &kp N6 &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N0 &kp N0 &kp B &kp N6>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp B &kp KP_N6>, <&macro_release &kp LALT>
        #endif
      )

      /* º */ UNICODE(world_o_ordinal,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp B &kp A &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N0 &kp N0 &kp B &kp A>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp B &kp A>, <&macro_release &kp LALT>
        #endif
      )

      /* ª */ UNICODE(world_a_ordinal,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp A &kp A &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N0 &kp N0 &kp A &kp A>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp A &kp A>, <&macro_release &kp LALT>
        #endif
      )

      /* ¡ */ UNICODE(world_exclaim_left,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp A &kp N1 &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N0 &kp N0 &kp A &kp N1>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp A &kp KP_N1>, <&macro_release &kp LALT>
        #endif
      )

      /* ¿ */ UNICODE(world_question_left,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp B &kp F &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N0 &kp N0 &kp B &kp F>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp B &kp F>, <&macro_release &kp LALT>
        #endif
      )

      /* « */ UNICODE(world_quote_left,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp A &kp B &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N0 &kp N0 &kp A &kp B>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp A &kp B>, <&macro_release &kp LALT>
        #endif
      )

      /* » */ UNICODE(world_quote_right,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp B &kp B &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N0 &kp N0 &kp B &kp B>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp B &kp B>, <&macro_release &kp LALT>
        #endif
      )

    //
    // characters
    //

      /* ç */ UNICODE(world_c_cedilla_lower,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp E &kp N7 &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N0 &kp N0 &kp E &kp N7>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp E &kp KP_N7>, <&macro_release &kp LALT>
        #endif
      )

      /* Ç */ UNICODE(world_c_cedilla_upper,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp C &kp N7 &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N0 &kp N0 &kp C &kp N7>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp C &kp KP_N7>, <&macro_release &kp LALT>
        #endif
      )

        world_c_cedilla: world_c_cedilla {
            compatible = "zmk,behavior-mod-morph";
            label = "WORLD_C_CEDILLA";
            #binding-cells = <0>;
            bindings = <&world_c_cedilla_lower>, <&world_c_cedilla_upper>;
            mods = <MOD_LSFT>;
        };

      /* í */ UNICODE(world_i_acute_lower,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp E &kp D &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N0 &kp N0 &kp E &kp D>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp E &kp D>, <&macro_release &kp LALT>
        #endif
      )

      /* Í */ UNICODE(world_i_acute_upper,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp C &kp D &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N0 &kp N0 &kp C &kp D>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp C &kp D>, <&macro_release &kp LALT>
        #endif
      )

        world_i_acute: world_i_acute {
            compatible = "zmk,behavior-mod-morph";
            label = "WORLD_I_ACUTE";
            #binding-cells = <0>;
            bindings = <&world_i_acute_lower>, <&world_i_acute_upper>;
            mods = <MOD_LSFT>;
        };

      /* ï */ UNICODE(world_i_diaeresis_lower,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp E &kp F &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N0 &kp N0 &kp E &kp F>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp E &kp F>, <&macro_release &kp LALT>
        #endif
      )

      /* Ï */ UNICODE(world_i_diaeresis_upper,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp C &kp F &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N0 &kp N0 &kp C &kp F>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp C &kp F>, <&macro_release &kp LALT>
        #endif
      )

        world_i_diaeresis: world_i_diaeresis {
            compatible = "zmk,behavior-mod-morph";
            label = "WORLD_I_DIAERESIS";
            #binding-cells = <0>;
            bindings = <&world_i_diaeresis_lower>, <&world_i_diaeresis_upper>;
            mods = <MOD_LSFT>;
        };

      /* î */ UNICODE(world_i_circumflex_lower,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp E &kp E &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N0 &kp N0 &kp E &kp E>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp E &kp E>, <&macro_release &kp LALT>
        #endif
      )

      /* Î */ UNICODE(world_i_circumflex_upper,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp C &kp E &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N0 &kp N0 &kp C &kp E>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp C &kp E>, <&macro_release &kp LALT>
        #endif
      )

        world_i_circumflex: world_i_circumflex {
            compatible = "zmk,behavior-mod-morph";
            label = "WORLD_I_CIRCUMFLEX";
            #binding-cells = <0>;
            bindings = <&world_i_circumflex_lower>, <&world_i_circumflex_upper>;
            mods = <MOD_LSFT>;
        };

      /* ì */ UNICODE(world_i_grave_lower,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp E &kp C &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N0 &kp N0 &kp E &kp C>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp E &kp C>, <&macro_release &kp LALT>
        #endif
      )

      /* Ì */ UNICODE(world_i_grave_upper,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp C &kp C &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N0 &kp N0 &kp C &kp C>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp C &kp C>, <&macro_release &kp LALT>
        #endif
      )

        world_i_grave: world_i_grave {
            compatible = "zmk,behavior-mod-morph";
            label = "WORLD_I_GRAVE";
            #binding-cells = <0>;
            bindings = <&world_i_grave_lower>, <&world_i_grave_upper>;
            mods = <MOD_LSFT>;
        };

      /* é */ UNICODE(world_e_acute_lower,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp E &kp N9 &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N0 &kp N0 &kp E &kp N9>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp E &kp KP_N9>, <&macro_release &kp LALT>
        #endif
      )

      /* É */ UNICODE(world_e_acute_upper,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp C &kp N9 &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N0 &kp N0 &kp C &kp N9>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp C &kp KP_N9>, <&macro_release &kp LALT>
        #endif
      )

        world_e_acute: world_e_acute {
            compatible = "zmk,behavior-mod-morph";
            label = "WORLD_E_ACUTE";
            #binding-cells = <0>;
            bindings = <&world_e_acute_lower>, <&world_e_acute_upper>;
            mods = <MOD_LSFT>;
        };

      /* ë */ UNICODE(world_e_diaeresis_lower,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp E &kp B &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N0 &kp N0 &kp E &kp B>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp E &kp B>, <&macro_release &kp LALT>
        #endif
      )

      /* Ë */ UNICODE(world_e_diaeresis_upper,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp C &kp B &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N0 &kp N0 &kp C &kp B>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp C &kp B>, <&macro_release &kp LALT>
        #endif
      )

        world_e_diaeresis: world_e_diaeresis {
            compatible = "zmk,behavior-mod-morph";
            label = "WORLD_E_DIAERESIS";
            #binding-cells = <0>;
            bindings = <&world_e_diaeresis_lower>, <&world_e_diaeresis_upper>;
            mods = <MOD_LSFT>;
        };

      /* ê */ UNICODE(world_e_circumflex_lower,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp E &kp A &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N0 &kp N0 &kp E &kp A>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp E &kp A>, <&macro_release &kp LALT>
        #endif
      )

      /* Ê */ UNICODE(world_e_circumflex_upper,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp C &kp A &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N0 &kp N0 &kp C &kp A>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp C &kp A>, <&macro_release &kp LALT>
        #endif
      )

        world_e_circumflex: world_e_circumflex {
            compatible = "zmk,behavior-mod-morph";
            label = "WORLD_E_CIRCUMFLEX";
            #binding-cells = <0>;
            bindings = <&world_e_circumflex_lower>, <&world_e_circumflex_upper>;
            mods = <MOD_LSFT>;
        };

      /* è */ UNICODE(world_e_grave_lower,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp E &kp N8 &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N0 &kp N0 &kp E &kp N8>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp E &kp KP_N8>, <&macro_release &kp LALT>
        #endif
      )

      /* È */ UNICODE(world_e_grave_upper,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp C &kp N8 &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N0 &kp N0 &kp C &kp N8>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp C &kp KP_N8>, <&macro_release &kp LALT>
        #endif
      )

        world_e_grave: world_e_grave {
            compatible = "zmk,behavior-mod-morph";
            label = "WORLD_E_GRAVE";
            #binding-cells = <0>;
            bindings = <&world_e_grave_lower>, <&world_e_grave_upper>;
            mods = <MOD_LSFT>;
        };

      /* æ */ UNICODE(world_e_ae_lower,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp E &kp N6 &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N0 &kp N0 &kp E &kp N6>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp E &kp KP_N6>, <&macro_release &kp LALT>
        #endif
      )

      /* Æ */ UNICODE(world_e_ae_upper,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp C &kp N6 &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N0 &kp N0 &kp C &kp N6>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp C &kp KP_N6>, <&macro_release &kp LALT>
        #endif
      )

        world_e_ae: world_e_ae {
            compatible = "zmk,behavior-mod-morph";
            label = "WORLD_E_AE";
            #binding-cells = <0>;
            bindings = <&world_e_ae_lower>, <&world_e_ae_upper>;
            mods = <MOD_LSFT>;
        };

      /* á */ UNICODE(world_a_acute_lower,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp E &kp N1 &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N0 &kp N0 &kp E &kp N1>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp E &kp KP_N1>, <&macro_release &kp LALT>
        #endif
      )

      /* Á */ UNICODE(world_a_acute_upper,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp C &kp N1 &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N0 &kp N0 &kp C &kp N1>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp C &kp KP_N1>, <&macro_release &kp LALT>
        #endif
      )

        world_a_acute: world_a_acute {
            compatible = "zmk,behavior-mod-morph";
            label = "WORLD_A_ACUTE";
            #binding-cells = <0>;
            bindings = <&world_a_acute_lower>, <&world_a_acute_upper>;
            mods = <MOD_LSFT>;
        };

      /* ä */ UNICODE(world_a_diaeresis_lower,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp E &kp N4 &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N0 &kp N0 &kp E &kp N4>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp E &kp KP_N4>, <&macro_release &kp LALT>
        #endif
      )

      /* Ä */ UNICODE(world_a_diaeresis_upper,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp C &kp N4 &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N0 &kp N0 &kp C &kp N4>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp C &kp KP_N4>, <&macro_release &kp LALT>
        #endif
      )

        world_a_diaeresis: world_a_diaeresis {
            compatible = "zmk,behavior-mod-morph";
            label = "WORLD_A_DIAERESIS";
            #binding-cells = <0>;
            bindings = <&world_a_diaeresis_lower>, <&world_a_diaeresis_upper>;
            mods = <MOD_LSFT>;
        };

      /* â */ UNICODE(world_a_circumflex_lower,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp E &kp N2 &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N0 &kp N0 &kp E &kp N2>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp E &kp KP_N2>, <&macro_release &kp LALT>
        #endif
      )

      /* Â */ UNICODE(world_a_circumflex_upper,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp C &kp N2 &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N0 &kp N0 &kp C &kp N2>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp C &kp KP_N2>, <&macro_release &kp LALT>
        #endif
      )

        world_a_circumflex: world_a_circumflex {
            compatible = "zmk,behavior-mod-morph";
            label = "WORLD_A_CIRCUMFLEX";
            #binding-cells = <0>;
            bindings = <&world_a_circumflex_lower>, <&world_a_circumflex_upper>;
            mods = <MOD_LSFT>;
        };

      /* à */ UNICODE(world_a_grave_lower,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp E &kp N0 &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N0 &kp N0 &kp E &kp N0>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp E &kp KP_N0>, <&macro_release &kp LALT>
        #endif
      )

      /* À */ UNICODE(world_a_grave_upper,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp C &kp N0 &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N0 &kp N0 &kp C &kp N0>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp C &kp KP_N0>, <&macro_release &kp LALT>
        #endif
      )

        world_a_grave: world_a_grave {
            compatible = "zmk,behavior-mod-morph";
            label = "WORLD_A_GRAVE";
            #binding-cells = <0>;
            bindings = <&world_a_grave_lower>, <&world_a_grave_upper>;
            mods = <MOD_LSFT>;
        };

      /* ã */ UNICODE(world_a_tilde_lower,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp E &kp N3 &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N0 &kp N0 &kp E &kp N3>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp E &kp KP_N3>, <&macro_release &kp LALT>
        #endif
      )

      /* Ã */ UNICODE(world_a_tilde_upper,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp C &kp N3 &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N0 &kp N0 &kp C &kp N3>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp C &kp KP_N3>, <&macro_release &kp LALT>
        #endif
      )

        world_a_tilde: world_a_tilde {
            compatible = "zmk,behavior-mod-morph";
            label = "WORLD_A_TILDE";
            #binding-cells = <0>;
            bindings = <&world_a_tilde_lower>, <&world_a_tilde_upper>;
            mods = <MOD_LSFT>;
        };

      /* å */ UNICODE(world_a_ring_lower,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp E &kp N5 &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N0 &kp N0 &kp E &kp N5>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp E &kp KP_N5>, <&macro_release &kp LALT>
        #endif
      )

      /* Å */ UNICODE(world_a_ring_upper,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp C &kp N5 &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N0 &kp N0 &kp C &kp N5>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp C &kp KP_N5>, <&macro_release &kp LALT>
        #endif
      )

        world_a_ring: world_a_ring {
            compatible = "zmk,behavior-mod-morph";
            label = "WORLD_A_RING";
            #binding-cells = <0>;
            bindings = <&world_a_ring_lower>, <&world_a_ring_upper>;
            mods = <MOD_LSFT>;
        };

      /* ý */ UNICODE(world_y_acute_lower,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp F &kp D &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N0 &kp N0 &kp F &kp D>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp F &kp D>, <&macro_release &kp LALT>
        #endif
      )

      /* Ý */ UNICODE(world_y_acute_upper,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp D &kp D &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N0 &kp N0 &kp D &kp D>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp D &kp D>, <&macro_release &kp LALT>
        #endif
      )

        world_y_acute: world_y_acute {
            compatible = "zmk,behavior-mod-morph";
            label = "WORLD_Y_ACUTE";
            #binding-cells = <0>;
            bindings = <&world_y_acute_lower>, <&world_y_acute_upper>;
            mods = <MOD_LSFT>;
        };

      /* ÿ */ UNICODE(world_y_diaeresis_lower,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp F &kp F &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N0 &kp N0 &kp F &kp F>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp F &kp F>, <&macro_release &kp LALT>
        #endif
      )

      /* Ÿ */ UNICODE(world_y_diaeresis_upper,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp N1 &kp N7 &kp N8 &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N0 &kp N1 &kp N7 &kp N8>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp KP_N1 &kp KP_N7 &kp KP_N8>, <&macro_release &kp LALT>
        #endif
      )

        world_y_diaeresis: world_y_diaeresis {
            compatible = "zmk,behavior-mod-morph";
            label = "WORLD_Y_DIAERESIS";
            #binding-cells = <0>;
            bindings = <&world_y_diaeresis_lower>, <&world_y_diaeresis_upper>;
            mods = <MOD_LSFT>;
        };

      /* ó */ UNICODE(world_o_acute_lower,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp F &kp N3 &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N0 &kp N0 &kp F &kp N3>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp F &kp KP_N3>, <&macro_release &kp LALT>
        #endif
      )

      /* Ó */ UNICODE(world_o_acute_upper,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp D &kp N3 &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N0 &kp N0 &kp D &kp N3>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp D &kp KP_N3>, <&macro_release &kp LALT>
        #endif
      )

        world_o_acute: world_o_acute {
            compatible = "zmk,behavior-mod-morph";
            label = "WORLD_O_ACUTE";
            #binding-cells = <0>;
            bindings = <&world_o_acute_lower>, <&world_o_acute_upper>;
            mods = <MOD_LSFT>;
        };

      /* ö */ UNICODE(world_o_diaeresis_lower,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp F &kp N6 &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N0 &kp N0 &kp F &kp N6>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp F &kp KP_N6>, <&macro_release &kp LALT>
        #endif
      )

      /* Ö */ UNICODE(world_o_diaeresis_upper,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp D &kp N6 &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N0 &kp N0 &kp D &kp N6>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp D &kp KP_N6>, <&macro_release &kp LALT>
        #endif
      )

        world_o_diaeresis: world_o_diaeresis {
            compatible = "zmk,behavior-mod-morph";
            label = "WORLD_O_DIAERESIS";
            #binding-cells = <0>;
            bindings = <&world_o_diaeresis_lower>, <&world_o_diaeresis_upper>;
            mods = <MOD_LSFT>;
        };

      /* ô */ UNICODE(world_o_circumflex_lower,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp F &kp N4 &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N0 &kp N0 &kp F &kp N4>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp F &kp KP_N4>, <&macro_release &kp LALT>
        #endif
      )

      /* Ô */ UNICODE(world_o_circumflex_upper,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp D &kp N4 &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N0 &kp N0 &kp D &kp N4>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp D &kp KP_N4>, <&macro_release &kp LALT>
        #endif
      )

        world_o_circumflex: world_o_circumflex {
            compatible = "zmk,behavior-mod-morph";
            label = "WORLD_O_CIRCUMFLEX";
            #binding-cells = <0>;
            bindings = <&world_o_circumflex_lower>, <&world_o_circumflex_upper>;
            mods = <MOD_LSFT>;
        };

      /* ò */ UNICODE(world_o_grave_lower,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp F &kp N2 &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N0 &kp N0 &kp F &kp N2>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp F &kp KP_N2>, <&macro_release &kp LALT>
        #endif
      )

      /* Ò */ UNICODE(world_o_grave_upper,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp D &kp N2 &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N0 &kp N0 &kp D &kp N2>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp D &kp KP_N2>, <&macro_release &kp LALT>
        #endif
      )

        world_o_grave: world_o_grave {
            compatible = "zmk,behavior-mod-morph";
            label = "WORLD_O_GRAVE";
            #binding-cells = <0>;
            bindings = <&world_o_grave_lower>, <&world_o_grave_upper>;
            mods = <MOD_LSFT>;
        };

      /* õ */ UNICODE(world_o_tilde_lower,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp F &kp N5 &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N0 &kp N0 &kp F &kp N5>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp F &kp KP_N5>, <&macro_release &kp LALT>
        #endif
      )

      /* Õ */ UNICODE(world_o_tilde_upper,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp D &kp N5 &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N0 &kp N0 &kp D &kp N5>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp D &kp KP_N5>, <&macro_release &kp LALT>
        #endif
      )

        world_o_tilde: world_o_tilde {
            compatible = "zmk,behavior-mod-morph";
            label = "WORLD_O_TILDE";
            #binding-cells = <0>;
            bindings = <&world_o_tilde_lower>, <&world_o_tilde_upper>;
            mods = <MOD_LSFT>;
        };

      /* ø */ UNICODE(world_o_slash_lower,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp F &kp N8 &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N0 &kp N0 &kp F &kp N8>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp F &kp KP_N8>, <&macro_release &kp LALT>
        #endif
      )

      /* Ø */ UNICODE(world_o_slash_upper,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp D &kp N8 &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N0 &kp N0 &kp D &kp N8>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp D &kp KP_N8>, <&macro_release &kp LALT>
        #endif
      )

        world_o_slash: world_o_slash {
            compatible = "zmk,behavior-mod-morph";
            label = "WORLD_O_SLASH";
            #binding-cells = <0>;
            bindings = <&world_o_slash_lower>, <&world_o_slash_upper>;
            mods = <MOD_LSFT>;
        };

      /* ú */ UNICODE(world_u_acute_lower,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp F &kp A &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N0 &kp N0 &kp F &kp A>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp F &kp A>, <&macro_release &kp LALT>
        #endif
      )

      /* Ú */ UNICODE(world_u_acute_upper,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp D &kp A &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N0 &kp N0 &kp D &kp A>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp D &kp A>, <&macro_release &kp LALT>
        #endif
      )

        world_u_acute: world_u_acute {
            compatible = "zmk,behavior-mod-morph";
            label = "WORLD_U_ACUTE";
            #binding-cells = <0>;
            bindings = <&world_u_acute_lower>, <&world_u_acute_upper>;
            mods = <MOD_LSFT>;
        };

      /* ü */ UNICODE(world_u_diaeresis_lower,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp F &kp C &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N0 &kp N0 &kp F &kp C>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp F &kp C>, <&macro_release &kp LALT>
        #endif
      )

      /* Ü */ UNICODE(world_u_diaeresis_upper,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp D &kp C &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N0 &kp N0 &kp D &kp C>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp D &kp C>, <&macro_release &kp LALT>
        #endif
      )

        world_u_diaeresis: world_u_diaeresis {
            compatible = "zmk,behavior-mod-morph";
            label = "WORLD_U_DIAERESIS";
            #binding-cells = <0>;
            bindings = <&world_u_diaeresis_lower>, <&world_u_diaeresis_upper>;
            mods = <MOD_LSFT>;
        };

      /* û */ UNICODE(world_u_circumflex_lower,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp F &kp B &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N0 &kp N0 &kp F &kp B>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp F &kp B>, <&macro_release &kp LALT>
        #endif
      )

      /* Û */ UNICODE(world_u_circumflex_upper,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp D &kp B &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N0 &kp N0 &kp D &kp B>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp D &kp B>, <&macro_release &kp LALT>
        #endif
      )

        world_u_circumflex: world_u_circumflex {
            compatible = "zmk,behavior-mod-morph";
            label = "WORLD_U_CIRCUMFLEX";
            #binding-cells = <0>;
            bindings = <&world_u_circumflex_lower>, <&world_u_circumflex_upper>;
            mods = <MOD_LSFT>;
        };

      /* ù */ UNICODE(world_u_grave_lower,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp F &kp N9 &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N0 &kp N0 &kp F &kp N9>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp F &kp KP_N9>, <&macro_release &kp LALT>
        #endif
      )

      /* Ù */ UNICODE(world_u_grave_upper,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp D &kp N9 &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N0 &kp N0 &kp D &kp N9>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp D &kp KP_N9>, <&macro_release &kp LALT>
        #endif
      )

        world_u_grave: world_u_grave {
            compatible = "zmk,behavior-mod-morph";
            label = "WORLD_U_GRAVE";
            #binding-cells = <0>;
            bindings = <&world_u_grave_lower>, <&world_u_grave_upper>;
            mods = <MOD_LSFT>;
        };

      /* ñ */ UNICODE(world_n_tilde_lower,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp F &kp N1 &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N0 &kp N0 &kp F &kp N1>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp F &kp KP_N1>, <&macro_release &kp LALT>
        #endif
      )

      /* Ñ */ UNICODE(world_n_tilde_upper,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp D &kp N1 &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N0 &kp N0 &kp D &kp N1>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp D &kp KP_N1>, <&macro_release &kp LALT>
        #endif
      )

        world_n_tilde: world_n_tilde {
            compatible = "zmk,behavior-mod-morph";
            label = "WORLD_N_TILDE";
            #binding-cells = <0>;
            bindings = <&world_n_tilde_lower>, <&world_n_tilde_upper>;
            mods = <MOD_LSFT>;
        };

    //
    // transforms
    //

        world_i_base: world_i_base {
            compatible = "zmk,behavior-mod-morph";
            label = "WORLD_I_BASE";
            #binding-cells = <0>;
            bindings = <&world_i_acute>, <&world_i_LCTL>;
            mods = <(MOD_LCTL|MOD_RCTL|MOD_RSFT)>;
        };

        world_i_LCTL: world_i_LCTL {
            compatible = "zmk,behavior-mod-morph";
            label = "WORLD_I_LCTL";
            #binding-cells = <0>;
            bindings = <&world_i_diaeresis>, <&world_i_RCTL>;
            mods = <(MOD_RCTL|MOD_RSFT)>;
        };

        world_i_RCTL: world_i_RCTL {
            compatible = "zmk,behavior-mod-morph";
            label = "WORLD_I_RCTL";
            #binding-cells = <0>;
            bindings = <&world_i_circumflex>, <&world_i_grave>;
            mods = <(MOD_RSFT)>;
        };

        world_e_base: world_e_base {
            compatible = "zmk,behavior-mod-morph";
            label = "WORLD_E_BASE";
            #binding-cells = <0>;
            bindings = <&world_e_acute>, <&world_e_RALT>;
            mods = <(MOD_RALT|MOD_LCTL|MOD_RCTL|MOD_RSFT)>;
        };

        world_e_RALT: world_e_RALT {
            compatible = "zmk,behavior-mod-morph";
            label = "WORLD_E_RALT";
            #binding-cells = <0>;
            bindings = <&world_e_ae>, <&world_e_LCTL>;
            mods = <(MOD_LCTL|MOD_RCTL|MOD_RSFT)>;
        };

        world_e_LCTL: world_e_LCTL {
            compatible = "zmk,behavior-mod-morph";
            label = "WORLD_E_LCTL";
            #binding-cells = <0>;
            bindings = <&world_e_diaeresis>, <&world_e_RCTL>;
            mods = <(MOD_RCTL|MOD_RSFT)>;
        };

        world_e_RCTL: world_e_RCTL {
            compatible = "zmk,behavior-mod-morph";
            label = "WORLD_E_RCTL";
            #binding-cells = <0>;
            bindings = <&world_e_circumflex>, <&world_e_grave>;
            mods = <(MOD_RSFT)>;
        };

        world_a_base: world_a_base {
            compatible = "zmk,behavior-mod-morph";
            label = "WORLD_A_BASE";
            #binding-cells = <0>;
            bindings = <&world_a_acute>, <&world_a_LALT>;
            mods = <(MOD_LALT|MOD_RALT|MOD_LCTL|MOD_RCTL|MOD_RSFT)>;
        };

        world_a_LALT: world_a_LALT {
            compatible = "zmk,behavior-mod-morph";
            label = "WORLD_A_LALT";
            #binding-cells = <0>;
            bindings = <&world_a_tilde>, <&world_a_RALT>;
            mods = <(MOD_RALT|MOD_LCTL|MOD_RCTL|MOD_RSFT)>;
        };

        world_a_RALT: world_a_RALT {
            compatible = "zmk,behavior-mod-morph";
            label = "WORLD_A_RALT";
            #binding-cells = <0>;
            bindings = <&world_a_ring>, <&world_a_LCTL>;
            mods = <(MOD_LCTL|MOD_RCTL|MOD_RSFT)>;
        };

        world_a_LCTL: world_a_LCTL {
            compatible = "zmk,behavior-mod-morph";
            label = "WORLD_A_LCTL";
            #binding-cells = <0>;
            bindings = <&world_a_diaeresis>, <&world_a_RCTL>;
            mods = <(MOD_RCTL|MOD_RSFT)>;
        };

        world_a_RCTL: world_a_RCTL {
            compatible = "zmk,behavior-mod-morph";
            label = "WORLD_A_RCTL";
            #binding-cells = <0>;
            bindings = <&world_a_circumflex>, <&world_a_grave>;
            mods = <(MOD_RSFT)>;
        };

        world_y_base: world_y_base {
            compatible = "zmk,behavior-mod-morph";
            label = "WORLD_Y_BASE";
            #binding-cells = <0>;
            bindings = <&world_y_acute>, <&world_y_diaeresis>;
            mods = <(MOD_LCTL)>;
        };

        world_o_base: world_o_base {
            compatible = "zmk,behavior-mod-morph";
            label = "WORLD_O_BASE";
            #binding-cells = <0>;
            bindings = <&world_o_acute>, <&world_o_LALT>;
            mods = <(MOD_LALT|MOD_RALT|MOD_LCTL|MOD_RCTL|MOD_RSFT)>;
        };

        world_o_LALT: world_o_LALT {
            compatible = "zmk,behavior-mod-morph";
            label = "WORLD_O_LALT";
            #binding-cells = <0>;
            bindings = <&world_o_tilde>, <&world_o_RALT>;
            mods = <(MOD_RALT|MOD_LCTL|MOD_RCTL|MOD_RSFT)>;
        };

        world_o_RALT: world_o_RALT {
            compatible = "zmk,behavior-mod-morph";
            label = "WORLD_O_RALT";
            #binding-cells = <0>;
            bindings = <&world_o_slash>, <&world_o_LCTL>;
            mods = <(MOD_LCTL|MOD_RCTL|MOD_RSFT)>;
        };

        world_o_LCTL: world_o_LCTL {
            compatible = "zmk,behavior-mod-morph";
            label = "WORLD_O_LCTL";
            #binding-cells = <0>;
            bindings = <&world_o_diaeresis>, <&world_o_RCTL>;
            mods = <(MOD_RCTL|MOD_RSFT)>;
        };

        world_o_RCTL: world_o_RCTL {
            compatible = "zmk,behavior-mod-morph";
            label = "WORLD_O_RCTL";
            #binding-cells = <0>;
            bindings = <&world_o_circumflex>, <&world_o_grave>;
            mods = <(MOD_RSFT)>;
        };

        world_u_base: world_u_base {
            compatible = "zmk,behavior-mod-morph";
            label = "WORLD_U_BASE";
            #binding-cells = <0>;
            bindings = <&world_u_acute>, <&world_u_LCTL>;
            mods = <(MOD_LCTL|MOD_RCTL|MOD_RSFT)>;
        };

        world_u_LCTL: world_u_LCTL {
            compatible = "zmk,behavior-mod-morph";
            label = "WORLD_U_LCTL";
            #binding-cells = <0>;
            bindings = <&world_u_diaeresis>, <&world_u_RCTL>;
            mods = <(MOD_RCTL|MOD_RSFT)>;
        };

        world_u_RCTL: world_u_RCTL {
            compatible = "zmk,behavior-mod-morph";
            label = "WORLD_U_RCTL";
            #binding-cells = <0>;
            bindings = <&world_u_circumflex>, <&world_u_grave>;
            mods = <(MOD_RSFT)>;
        };

    //////////////////////////////////////////////////////////////////////////
    //
    // Emoji layer - modern age pictograms
    //
    //////////////////////////////////////////////////////////////////////////

    //
    // EMOJI_GENDER_SIGN_PRESET defines an Emoji gender sign for use as a
    // convenient inward-rolling shortcut on the home row of the layer.
    //
    #ifndef EMOJI_GENDER_SIGN_PRESET
    //#define EMOJI_GENDER_SIGN_PRESET 0 // neutral
    #define EMOJI_GENDER_SIGN_PRESET 1 // male
    //#define EMOJI_GENDER_SIGN_PRESET 2 // female
    #endif

    //
    // EMOJI_SKIN_TONE_PRESET defines an Emoji skin tone for use as a
    // convenient inward-rolling shortcut on the home row of the layer.
    //
    #ifndef EMOJI_SKIN_TONE_PRESET
    //#define EMOJI_SKIN_TONE_PRESET 0 // neutral
    //#define EMOJI_SKIN_TONE_PRESET 1 // light_skin_tone
    //#define EMOJI_SKIN_TONE_PRESET 2 // medium_light_skin_tone
    //#define EMOJI_SKIN_TONE_PRESET 3 // medium_skin_tone
    #define EMOJI_SKIN_TONE_PRESET 4 // medium_dark_skin_tone
    //#define EMOJI_SKIN_TONE_PRESET 5 // dark_skin_tone
    #endif

    //
    // EMOJI_HAIR_STYLE_PRESET defines an Emoji hair style for use as a
    // convenient inward-rolling shortcut on the home row of the layer.
    //
    #ifndef EMOJI_HAIR_STYLE_PRESET
    //#define EMOJI_HAIR_STYLE_PRESET 0 // neutral
    //#define EMOJI_HAIR_STYLE_PRESET 1 // bald
    //#define EMOJI_HAIR_STYLE_PRESET 2 // red_hair
    //#define EMOJI_HAIR_STYLE_PRESET 3 // curly_hair
    #define EMOJI_HAIR_STYLE_PRESET 4 // white_hair
    #endif

    //
    // NOTE: edit the emoji.yaml file and run `rake` to generate this:
    //

      /* ‍ */ UNICODE(emoji_zwj,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp N2 &kp N0 &kp N0 &kp D &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N2 &kp N0 &kp N0 &kp D>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp KP_N2 &kp KP_N0 &kp KP_N0 &kp D>, <&macro_release &kp LALT>
        #endif
      )

      /* ♂️ */ UNICODE(emoji_male_sign,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp N2 &kp N6 &kp N4 &kp N2 &kp ENTER>, <&macro_wait_time UNICODE_SEQ_DELAY>, <&kp LC(LS(U)) &kp F &kp E &kp N0 &kp F &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N2 &kp N6 &kp N4 &kp N2>, <&macro_release &kp LALT>, <&macro_wait_time UNICODE_SEQ_DELAY>, <&macro_press &kp LALT>, <&macro_tap &kp F &kp E &kp N0 &kp F>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp KP_N2 &kp KP_N6 &kp KP_N4 &kp KP_N2>, <&macro_release &kp LALT>, <&macro_wait_time UNICODE_SEQ_DELAY>, <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp F &kp E &kp KP_N0 &kp F>, <&macro_release &kp LALT>
        #endif
      )

      /* ♀️ */ UNICODE(emoji_female_sign,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp N2 &kp N6 &kp N4 &kp N0 &kp ENTER>, <&macro_wait_time UNICODE_SEQ_DELAY>, <&kp LC(LS(U)) &kp F &kp E &kp N0 &kp F &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N2 &kp N6 &kp N4 &kp N0>, <&macro_release &kp LALT>, <&macro_wait_time UNICODE_SEQ_DELAY>, <&macro_press &kp LALT>, <&macro_tap &kp F &kp E &kp N0 &kp F>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp KP_N2 &kp KP_N6 &kp KP_N4 &kp KP_N0>, <&macro_release &kp LALT>, <&macro_wait_time UNICODE_SEQ_DELAY>, <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp F &kp E &kp KP_N0 &kp F>, <&macro_release &kp LALT>
        #endif
      )

      /* ➡️ */ UNICODE(emoji_right_arrow,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp N2 &kp N7 &kp A &kp N1 &kp ENTER>, <&macro_wait_time UNICODE_SEQ_DELAY>, <&kp LC(LS(U)) &kp F &kp E &kp N0 &kp F &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N2 &kp N7 &kp A &kp N1>, <&macro_release &kp LALT>, <&macro_wait_time UNICODE_SEQ_DELAY>, <&macro_press &kp LALT>, <&macro_tap &kp F &kp E &kp N0 &kp F>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp KP_N2 &kp KP_N7 &kp A &kp KP_N1>, <&macro_release &kp LALT>, <&macro_wait_time UNICODE_SEQ_DELAY>, <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp F &kp E &kp KP_N0 &kp F>, <&macro_release &kp LALT>
        #endif
      )

      /* ⬅️ */ UNICODE(emoji_left_arrow,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp N2 &kp B &kp N0 &kp N5 &kp ENTER>, <&macro_wait_time UNICODE_SEQ_DELAY>, <&kp LC(LS(U)) &kp F &kp E &kp N0 &kp F &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N2 &kp B &kp N0 &kp N5>, <&macro_release &kp LALT>, <&macro_wait_time UNICODE_SEQ_DELAY>, <&macro_press &kp LALT>, <&macro_tap &kp F &kp E &kp N0 &kp F>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp KP_N2 &kp B &kp KP_N0 &kp KP_N5>, <&macro_release &kp LALT>, <&macro_wait_time UNICODE_SEQ_DELAY>, <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp F &kp E &kp KP_N0 &kp F>, <&macro_release &kp LALT>
        #endif
      )

      /* 🏻 */ UNICODE(emoji_light_skin_tone,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp N1 &kp F &kp N3 &kp F &kp B &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N1 &kp F &kp N3 &kp F &kp B>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp KP_N1 &kp F &kp KP_N3 &kp F &kp B>, <&macro_release &kp LALT>
        #endif
      )

      /* 🏼 */ UNICODE(emoji_medium_light_skin_tone,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp N1 &kp F &kp N3 &kp F &kp C &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N1 &kp F &kp N3 &kp F &kp C>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp KP_N1 &kp F &kp KP_N3 &kp F &kp C>, <&macro_release &kp LALT>
        #endif
      )

      /* 🏽 */ UNICODE(emoji_medium_skin_tone,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp N1 &kp F &kp N3 &kp F &kp D &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N1 &kp F &kp N3 &kp F &kp D>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp KP_N1 &kp F &kp KP_N3 &kp F &kp D>, <&macro_release &kp LALT>
        #endif
      )

      /* 🏾 */ UNICODE(emoji_medium_dark_skin_tone,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp N1 &kp F &kp N3 &kp F &kp E &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N1 &kp F &kp N3 &kp F &kp E>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp KP_N1 &kp F &kp KP_N3 &kp F &kp E>, <&macro_release &kp LALT>
        #endif
      )

      /* 🏿 */ UNICODE(emoji_dark_skin_tone,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp N1 &kp F &kp N3 &kp F &kp F &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N1 &kp F &kp N3 &kp F &kp F>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp KP_N1 &kp F &kp KP_N3 &kp F &kp F>, <&macro_release &kp LALT>
        #endif
      )

      /* 🍼 */ UNICODE(emoji_baby_bottle,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp N1 &kp F &kp N3 &kp N7 &kp C &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N1 &kp F &kp N3 &kp N7 &kp C>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp KP_N1 &kp F &kp KP_N3 &kp KP_N7 &kp C>, <&macro_release &kp LALT>
        #endif
      )

      /* 👶 */ UNICODE(emoji_baby,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp N1 &kp F &kp N4 &kp N7 &kp N6 &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N1 &kp F &kp N4 &kp N7 &kp N6>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp KP_N1 &kp F &kp KP_N4 &kp KP_N7 &kp KP_N6>, <&macro_release &kp LALT>
        #endif
      )

      /* 👦 */ UNICODE(emoji_boy,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp N1 &kp F &kp N4 &kp N6 &kp N6 &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N1 &kp F &kp N4 &kp N6 &kp N6>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp KP_N1 &kp F &kp KP_N4 &kp KP_N6 &kp KP_N6>, <&macro_release &kp LALT>
        #endif
      )

      /* 👧 */ UNICODE(emoji_girl,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp N1 &kp F &kp N4 &kp N6 &kp N7 &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N1 &kp F &kp N4 &kp N6 &kp N7>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp KP_N1 &kp F &kp KP_N4 &kp KP_N6 &kp KP_N7>, <&macro_release &kp LALT>
        #endif
      )

      /* 👨 */ UNICODE(emoji_man,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp N1 &kp F &kp N4 &kp N6 &kp N8 &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N1 &kp F &kp N4 &kp N6 &kp N8>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp KP_N1 &kp F &kp KP_N4 &kp KP_N6 &kp KP_N8>, <&macro_release &kp LALT>
        #endif
      )

      /* 👩 */ UNICODE(emoji_woman,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp N1 &kp F &kp N4 &kp N6 &kp N9 &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N1 &kp F &kp N4 &kp N6 &kp N9>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp KP_N1 &kp F &kp KP_N4 &kp KP_N6 &kp KP_N9>, <&macro_release &kp LALT>
        #endif
      )

      /* 👴 */ UNICODE(emoji_old_man,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp N1 &kp F &kp N4 &kp N7 &kp N4 &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N1 &kp F &kp N4 &kp N7 &kp N4>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp KP_N1 &kp F &kp KP_N4 &kp KP_N7 &kp KP_N4>, <&macro_release &kp LALT>
        #endif
      )

      /* 👵 */ UNICODE(emoji_old_woman,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp N1 &kp F &kp N4 &kp N7 &kp N5 &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N1 &kp F &kp N4 &kp N7 &kp N5>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp KP_N1 &kp F &kp KP_N4 &kp KP_N7 &kp KP_N5>, <&macro_release &kp LALT>
        #endif
      )

      /* 🦳 */ UNICODE(emoji_white_hair,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp N1 &kp F &kp N9 &kp B &kp N3 &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N1 &kp F &kp N9 &kp B &kp N3>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp KP_N1 &kp F &kp KP_N9 &kp B &kp KP_N3>, <&macro_release &kp LALT>
        #endif
      )

      /* 🦱 */ UNICODE(emoji_curly_hair,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp N1 &kp F &kp N9 &kp B &kp N1 &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N1 &kp F &kp N9 &kp B &kp N1>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp KP_N1 &kp F &kp KP_N9 &kp B &kp KP_N1>, <&macro_release &kp LALT>
        #endif
      )

      /* 🦰 */ UNICODE(emoji_red_hair,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp N1 &kp F &kp N9 &kp B &kp N0 &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N1 &kp F &kp N9 &kp B &kp N0>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp KP_N1 &kp F &kp KP_N9 &kp B &kp KP_N0>, <&macro_release &kp LALT>
        #endif
      )

      /* 🦲 */ UNICODE(emoji_bald,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp N1 &kp F &kp N9 &kp B &kp N2 &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N1 &kp F &kp N9 &kp B &kp N2>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp KP_N1 &kp F &kp KP_N9 &kp B &kp KP_N2>, <&macro_release &kp LALT>
        #endif
      )

      /* 🌑 */ UNICODE(emoji_new_moon,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp N1 &kp F &kp N3 &kp N1 &kp N1 &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N1 &kp F &kp N3 &kp N1 &kp N1>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp KP_N1 &kp F &kp KP_N3 &kp KP_N1 &kp KP_N1>, <&macro_release &kp LALT>
        #endif
      )

      /* 🌒 */ UNICODE(emoji_waxing_crescent_moon,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp N1 &kp F &kp N3 &kp N1 &kp N2 &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N1 &kp F &kp N3 &kp N1 &kp N2>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp KP_N1 &kp F &kp KP_N3 &kp KP_N1 &kp KP_N2>, <&macro_release &kp LALT>
        #endif
      )

      /* 🌓 */ UNICODE(emoji_first_quarter_moon,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp N1 &kp F &kp N3 &kp N1 &kp N3 &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N1 &kp F &kp N3 &kp N1 &kp N3>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp KP_N1 &kp F &kp KP_N3 &kp KP_N1 &kp KP_N3>, <&macro_release &kp LALT>
        #endif
      )

      /* 🌔 */ UNICODE(emoji_waxing_gibbous_moon,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp N1 &kp F &kp N3 &kp N1 &kp N4 &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N1 &kp F &kp N3 &kp N1 &kp N4>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp KP_N1 &kp F &kp KP_N3 &kp KP_N1 &kp KP_N4>, <&macro_release &kp LALT>
        #endif
      )

      /* 🌕 */ UNICODE(emoji_full_moon,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp N1 &kp F &kp N3 &kp N1 &kp N5 &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N1 &kp F &kp N3 &kp N1 &kp N5>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp KP_N1 &kp F &kp KP_N3 &kp KP_N1 &kp KP_N5>, <&macro_release &kp LALT>
        #endif
      )

      /* 🎉 */ UNICODE(emoji_tada,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp N1 &kp F &kp N3 &kp N8 &kp N9 &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N1 &kp F &kp N3 &kp N8 &kp N9>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp KP_N1 &kp F &kp KP_N3 &kp KP_N8 &kp KP_N9>, <&macro_release &kp LALT>
        #endif
      )

      /* 🔥 */ UNICODE(emoji_fire,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp N1 &kp F &kp N5 &kp N2 &kp N5 &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N1 &kp F &kp N5 &kp N2 &kp N5>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp KP_N1 &kp F &kp KP_N5 &kp KP_N2 &kp KP_N5>, <&macro_release &kp LALT>
        #endif
      )

      /* ️❤️ */ UNICODE(emoji_heart,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp F &kp E &kp N0 &kp F &kp ENTER>, <&macro_wait_time UNICODE_SEQ_DELAY>, <&kp LC(LS(U)) &kp N2 &kp N7 &kp N6 &kp N4 &kp ENTER>, <&kp LC(LS(U)) &kp F &kp E &kp N0 &kp F &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp F &kp E &kp N0 &kp F>, <&macro_release &kp LALT>, <&macro_wait_time UNICODE_SEQ_DELAY>, <&macro_press &kp LALT>, <&macro_tap &kp N2 &kp N7 &kp N6 &kp N4>, <&macro_release &kp LALT>, <&macro_press &kp LALT>, <&macro_tap &kp F &kp E &kp N0 &kp F>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp F &kp E &kp KP_N0 &kp F>, <&macro_release &kp LALT>, <&macro_wait_time UNICODE_SEQ_DELAY>, <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp KP_N2 &kp KP_N7 &kp KP_N6 &kp KP_N4>, <&macro_release &kp LALT>, <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp F &kp E &kp KP_N0 &kp F>, <&macro_release &kp LALT>
        #endif
      )

      /* 💪 */ UNICODE(emoji_muscle,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp N1 &kp F &kp N4 &kp A &kp A &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N1 &kp F &kp N4 &kp A &kp A>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp KP_N1 &kp F &kp KP_N4 &kp A &kp A>, <&macro_release &kp LALT>
        #endif
      )

      /* 🧗 */ UNICODE(emoji_person_climbing,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp N1 &kp F &kp N9 &kp D &kp N7 &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N1 &kp F &kp N9 &kp D &kp N7>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp KP_N1 &kp F &kp KP_N9 &kp D &kp KP_N7>, <&macro_release &kp LALT>
        #endif
      )

      /* 🚀 */ UNICODE(emoji_rocket,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp N1 &kp F &kp N6 &kp N8 &kp N0 &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N1 &kp F &kp N6 &kp N8 &kp N0>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp KP_N1 &kp F &kp KP_N6 &kp KP_N8 &kp KP_N0>, <&macro_release &kp LALT>
        #endif
      )

      /* 😎 */ UNICODE(emoji_sunglasses,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp N1 &kp F &kp N6 &kp N0 &kp E &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N1 &kp F &kp N6 &kp N0 &kp E>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp KP_N1 &kp F &kp KP_N6 &kp KP_N0 &kp E>, <&macro_release &kp LALT>
        #endif
      )

      /* 🤩 */ UNICODE(emoji_star_struck,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp N1 &kp F &kp N9 &kp N2 &kp N9 &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N1 &kp F &kp N9 &kp N2 &kp N9>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp KP_N1 &kp F &kp KP_N9 &kp KP_N2 &kp KP_N9>, <&macro_release &kp LALT>
        #endif
      )

      /* 😂 */ UNICODE(emoji_joy,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp N1 &kp F &kp N6 &kp N0 &kp N2 &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N1 &kp F &kp N6 &kp N0 &kp N2>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp KP_N1 &kp F &kp KP_N6 &kp KP_N0 &kp KP_N2>, <&macro_release &kp LALT>
        #endif
      )

      /* 😰 */ UNICODE(emoji_cold_sweat,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp N1 &kp F &kp N6 &kp N3 &kp N0 &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N1 &kp F &kp N6 &kp N3 &kp N0>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp KP_N1 &kp F &kp KP_N6 &kp KP_N3 &kp KP_N0>, <&macro_release &kp LALT>
        #endif
      )

      /* 😱 */ UNICODE(emoji_scream,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp N1 &kp F &kp N6 &kp N3 &kp N1 &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N1 &kp F &kp N6 &kp N3 &kp N1>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp KP_N1 &kp F &kp KP_N6 &kp KP_N3 &kp KP_N1>, <&macro_release &kp LALT>
        #endif
      )

      /* 🤯 */ UNICODE(emoji_exploding_head,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp N1 &kp F &kp N9 &kp N2 &kp F &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N1 &kp F &kp N9 &kp N2 &kp F>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp KP_N1 &kp F &kp KP_N9 &kp KP_N2 &kp F>, <&macro_release &kp LALT>
        #endif
      )

      /* 🫰 */ UNICODE(emoji_snap_fingers,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp N1 &kp F &kp A &kp F &kp N0 &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N1 &kp F &kp A &kp F &kp N0>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp KP_N1 &kp F &kp A &kp F &kp KP_N0>, <&macro_release &kp LALT>
        #endif
      )

      /* 👌 */ UNICODE(emoji_ok_hand,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp N1 &kp F &kp N4 &kp N4 &kp C &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N1 &kp F &kp N4 &kp N4 &kp C>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp KP_N1 &kp F &kp KP_N4 &kp KP_N4 &kp C>, <&macro_release &kp LALT>
        #endif
      )

      /* 🙏 */ UNICODE(emoji_pray,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp N1 &kp F &kp N6 &kp N4 &kp F &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N1 &kp F &kp N6 &kp N4 &kp F>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp KP_N1 &kp F &kp KP_N6 &kp KP_N4 &kp F>, <&macro_release &kp LALT>
        #endif
      )

      /* 😅 */ UNICODE(emoji_sweat_smile,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp N1 &kp F &kp N6 &kp N0 &kp N5 &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N1 &kp F &kp N6 &kp N0 &kp N5>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp KP_N1 &kp F &kp KP_N6 &kp KP_N0 &kp KP_N5>, <&macro_release &kp LALT>
        #endif
      )

      /* 😞 */ UNICODE(emoji_disappointed,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp N1 &kp F &kp N6 &kp N1 &kp E &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N1 &kp F &kp N6 &kp N1 &kp E>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp KP_N1 &kp F &kp KP_N6 &kp KP_N1 &kp E>, <&macro_release &kp LALT>
        #endif
      )

      /* 🤔 */ UNICODE(emoji_thinking,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp N1 &kp F &kp N9 &kp N1 &kp N4 &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N1 &kp F &kp N9 &kp N1 &kp N4>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp KP_N1 &kp F &kp KP_N9 &kp KP_N1 &kp KP_N4>, <&macro_release &kp LALT>
        #endif
      )

      /* 💁 */ UNICODE(emoji_person_tipping_hand,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp N1 &kp F &kp N4 &kp N8 &kp N1 &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N1 &kp F &kp N4 &kp N8 &kp N1>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp KP_N1 &kp F &kp KP_N4 &kp KP_N8 &kp KP_N1>, <&macro_release &kp LALT>
        #endif
      )

      /* 🙆 */ UNICODE(emoji_person_gesturing_ok,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp N1 &kp F &kp N6 &kp N4 &kp N6 &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N1 &kp F &kp N6 &kp N4 &kp N6>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp KP_N1 &kp F &kp KP_N6 &kp KP_N4 &kp KP_N6>, <&macro_release &kp LALT>
        #endif
      )

      /* 🙇 */ UNICODE(emoji_person_bowing,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp N1 &kp F &kp N6 &kp N4 &kp N7 &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N1 &kp F &kp N6 &kp N4 &kp N7>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp KP_N1 &kp F &kp KP_N6 &kp KP_N4 &kp KP_N7>, <&macro_release &kp LALT>
        #endif
      )

      /* 🙋 */ UNICODE(emoji_person_raising_hand,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp N1 &kp F &kp N6 &kp N4 &kp B &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N1 &kp F &kp N6 &kp N4 &kp B>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp KP_N1 &kp F &kp KP_N6 &kp KP_N4 &kp B>, <&macro_release &kp LALT>
        #endif
      )

      /* 🙅 */ UNICODE(emoji_person_gesturing_no,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp N1 &kp F &kp N6 &kp N4 &kp N5 &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N1 &kp F &kp N6 &kp N4 &kp N5>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp KP_N1 &kp F &kp KP_N6 &kp KP_N4 &kp KP_N5>, <&macro_release &kp LALT>
        #endif
      )

      /* 🤷 */ UNICODE(emoji_person_shrugging,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp N1 &kp F &kp N9 &kp N3 &kp N7 &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N1 &kp F &kp N9 &kp N3 &kp N7>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp KP_N1 &kp F &kp KP_N9 &kp KP_N3 &kp KP_N7>, <&macro_release &kp LALT>
        #endif
      )

      /* ✅ */ UNICODE(emoji_checkoff,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp N2 &kp N7 &kp N0 &kp N5 &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N2 &kp N7 &kp N0 &kp N5>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp KP_N2 &kp KP_N7 &kp KP_N0 &kp KP_N5>, <&macro_release &kp LALT>
        #endif
      )

      /* 💯 */ UNICODE(emoji_100,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp N1 &kp F &kp N4 &kp A &kp F &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N1 &kp F &kp N4 &kp A &kp F>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp KP_N1 &kp F &kp KP_N4 &kp A &kp F>, <&macro_release &kp LALT>
        #endif
      )

      /* ⚠️ */ UNICODE(emoji_warning,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp N2 &kp N6 &kp A &kp N0 &kp ENTER>, <&macro_wait_time UNICODE_SEQ_DELAY>, <&kp LC(LS(U)) &kp F &kp E &kp N0 &kp F &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N2 &kp N6 &kp A &kp N0>, <&macro_release &kp LALT>, <&macro_wait_time UNICODE_SEQ_DELAY>, <&macro_press &kp LALT>, <&macro_tap &kp F &kp E &kp N0 &kp F>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp KP_N2 &kp KP_N6 &kp A &kp KP_N0>, <&macro_release &kp LALT>, <&macro_wait_time UNICODE_SEQ_DELAY>, <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp F &kp E &kp KP_N0 &kp F>, <&macro_release &kp LALT>
        #endif
      )

      /* ❌ */ UNICODE(emoji_x,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp N2 &kp N7 &kp N4 &kp C &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N2 &kp N7 &kp N4 &kp C>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp KP_N2 &kp KP_N7 &kp KP_N4 &kp C>, <&macro_release &kp LALT>
        #endif
      )

      /* ❓ */ UNICODE(emoji_question,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp N2 &kp N7 &kp N5 &kp N3 &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N2 &kp N7 &kp N5 &kp N3>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp KP_N2 &kp KP_N7 &kp KP_N5 &kp KP_N3>, <&macro_release &kp LALT>
        #endif
      )

      /* 🧑‍🚀 */ UNICODE(emoji_astronaut,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp N1 &kp F &kp N9 &kp D &kp N1 &kp ENTER>, <&macro_wait_time UNICODE_SEQ_DELAY>, <&kp LC(LS(U)) &kp N2 &kp N0 &kp N0 &kp D &kp ENTER>, <&kp LC(LS(U)) &kp N1 &kp F &kp N6 &kp N8 &kp N0 &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N1 &kp F &kp N9 &kp D &kp N1>, <&macro_release &kp LALT>, <&macro_wait_time UNICODE_SEQ_DELAY>, <&macro_press &kp LALT>, <&macro_tap &kp N2 &kp N0 &kp N0 &kp D>, <&macro_release &kp LALT>, <&macro_press &kp LALT>, <&macro_tap &kp N1 &kp F &kp N6 &kp N8 &kp N0>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp KP_N1 &kp F &kp KP_N9 &kp D &kp KP_N1>, <&macro_release &kp LALT>, <&macro_wait_time UNICODE_SEQ_DELAY>, <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp KP_N2 &kp KP_N0 &kp KP_N0 &kp D>, <&macro_release &kp LALT>, <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp KP_N1 &kp F &kp KP_N6 &kp KP_N8 &kp KP_N0>, <&macro_release &kp LALT>
        #endif
      )

      /* 🤓 */ UNICODE(emoji_nerd,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp N1 &kp F &kp N9 &kp N1 &kp N3 &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N1 &kp F &kp N9 &kp N1 &kp N3>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp KP_N1 &kp F &kp KP_N9 &kp KP_N1 &kp KP_N3>, <&macro_release &kp LALT>
        #endif
      )

      /* ✨ */ UNICODE(emoji_sparkles,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp N2 &kp N7 &kp N2 &kp N8 &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N2 &kp N7 &kp N2 &kp N8>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp KP_N2 &kp KP_N7 &kp KP_N2 &kp KP_N8>, <&macro_release &kp LALT>
        #endif
      )

      /* 🙌 */ UNICODE(emoji_raised_hands,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp N1 &kp F &kp N6 &kp N4 &kp C &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N1 &kp F &kp N6 &kp N4 &kp C>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp KP_N1 &kp F &kp KP_N6 &kp KP_N4 &kp C>, <&macro_release &kp LALT>
        #endif
      )

      /* ☝️ */ UNICODE(emoji_point_up,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp N2 &kp N6 &kp N1 &kp D &kp ENTER>, <&macro_wait_time UNICODE_SEQ_DELAY>, <&kp LC(LS(U)) &kp F &kp E &kp N0 &kp F &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N2 &kp N6 &kp N1 &kp D>, <&macro_release &kp LALT>, <&macro_wait_time UNICODE_SEQ_DELAY>, <&macro_press &kp LALT>, <&macro_tap &kp F &kp E &kp N0 &kp F>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp KP_N2 &kp KP_N6 &kp KP_N1 &kp D>, <&macro_release &kp LALT>, <&macro_wait_time UNICODE_SEQ_DELAY>, <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp F &kp E &kp KP_N0 &kp F>, <&macro_release &kp LALT>
        #endif
      )

      /* 👍 */ UNICODE(emoji_thumbs_up,
        #if UNICODE_TARGET_OS == 1
          <&kp LC(LS(U)) &kp N1 &kp F &kp N4 &kp N4 &kp D &kp ENTER>
        #elif UNICODE_TARGET_OS == 2
          <&macro_press &kp LALT>, <&macro_tap &kp N1 &kp F &kp N4 &kp N4 &kp D>, <&macro_release &kp LALT>
        #elif UNICODE_TARGET_OS == 3
          <&macro_press &kp LALT>, <&macro_tap &kp KP_PLUS &kp KP_N1 &kp F &kp KP_N4 &kp KP_N4 &kp D>, <&macro_release &kp LALT>
        #endif
      )

};

/*HACK*/};
    #if EMOJI_GENDER_SIGN_PRESET == 0
      emoji_gender_sign_preset: &none {};
    #elif EMOJI_GENDER_SIGN_PRESET == 1
      emoji_gender_sign_preset: &emoji_male_sign {};
    #elif EMOJI_GENDER_SIGN_PRESET == 2
      emoji_gender_sign_preset: &emoji_female_sign {};
    #endif
    #if EMOJI_SKIN_TONE_PRESET == 0
      emoji_skin_tone_preset: &none {};
    #elif EMOJI_SKIN_TONE_PRESET == 1
      emoji_skin_tone_preset: &emoji_light_skin_tone {};
    #elif EMOJI_SKIN_TONE_PRESET == 2
      emoji_skin_tone_preset: &emoji_medium_light_skin_tone {};
    #elif EMOJI_SKIN_TONE_PRESET == 3
      emoji_skin_tone_preset: &emoji_medium_skin_tone {};
    #elif EMOJI_SKIN_TONE_PRESET == 4
      emoji_skin_tone_preset: &emoji_medium_dark_skin_tone {};
    #elif EMOJI_SKIN_TONE_PRESET == 5
      emoji_skin_tone_preset: &emoji_dark_skin_tone {};
    #endif
    #if EMOJI_HAIR_STYLE_PRESET == 0
      emoji_hair_style_preset: &none {};
    #elif EMOJI_HAIR_STYLE_PRESET == 1
      emoji_hair_style_preset: &emoji_bald {};
    #elif EMOJI_HAIR_STYLE_PRESET == 2
      emoji_hair_style_preset: &emoji_red_hair {};
    #elif EMOJI_HAIR_STYLE_PRESET == 3
      emoji_hair_style_preset: &emoji_curly_hair {};
    #elif EMOJI_HAIR_STYLE_PRESET == 4
      emoji_hair_style_preset: &emoji_white_hair {};
    #endif
/*HACK*//{

