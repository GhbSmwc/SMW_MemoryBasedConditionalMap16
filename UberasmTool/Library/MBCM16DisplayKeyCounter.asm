	incsrc "../FlagMemoryDefines/Defines.asm"
;Execute like this:
;in level:
;	init:						;>Init so the counter displays as the level loads.
;	LDY #$xx					;>$xx is what key counter to use, as an index from !Freeram_MBCM16_KeyCounter.
;	JSL MBCM16DisplayKeyCounter_DisplayHud
;	;[...]
;	RTL
;	main:
;	LDY #$xx					;>$xx is what key counter to use, as an index from !Freeram_MBCM16_KeyCounter.
;	JSL MBCM16DisplayKeyCounter_DisplayHud
;	;[...]
;	RTL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Display key counter on the HUD
;
;Y index = Index from !Freeram_MBCM16_KeyCounter.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
DisplayHud:
	;(note to self, place code that loads a level number and determine what Y index/key counter to use, and make sure this doesn't run every frame!)
	;
	.ClearTiles
		LDX.b #(!StatusbarFormat*$03)
	
		..Loop
			LDA #!Settings_MBCM16_KeyCounterBlankTileNumb
			STA !Settings_MBCM16_KeyCounterTileNumbPos,x
			if !EditTileProps != 0
				LDA #!Settings_MBCM16_KeyCounterBlankTileProp
				STA !Settings_MBCM16_KeyCounterTilePropPos,x
			endif
			DEX #!StatusbarFormat
			BPL ..Loop
	
		TYX								;>Transfer key counter index to X.
		LDA !Freeram_MBCM16_KeyCounter,x
		BEQ .Done							;>If current key counter is 0, don't display key counter.
	.WriteTilePrefix
		;Write <keysymbol>X<1 or 2 digits here>
		LDA #!Settings_MBCM16_KeyCounterKeySymbolTileNumb : STA !Settings_MBCM16_KeyCounterTileNumbPos
		if !EditTileProps != 0
			LDA #!Settings_MBCM16_KeyCounterKeySymbolTileProp : STA !Settings_MBCM16_KeyCounterTilePropPos
		endif
		LDA #!Settings_MBCM16_KeyCounterXSymbolTileNumb : STA !Settings_MBCM16_KeyCounterTileNumbPos+(!StatusbarFormat*$01)
		if !EditTileProps != 0
			LDA #!Settings_MBCM16_KeyCounterXSymbolTileProp : STA !Settings_MBCM16_KeyCounterTilePropPos+(!StatusbarFormat*$01)
		endif
	
	.WriteDigits
		if !EditTileProps != 0
			LDA.b #!Settings_MBCM16_KeyCounterDigitsTileProp
			STA !Settings_MBCM16_KeyCounterTilePropPos+(!StatusbarFormat*$02)
			STA !Settings_MBCM16_KeyCounterTilePropPos+(!StatusbarFormat*$03)
		endif
	
		LDA !Freeram_MBCM16_KeyCounter,x
		CMP.b #10
		BCS ..TwoDigits
	
		..OneDigit
			STA !Settings_MBCM16_KeyCounterTileNumbPos+(!StatusbarFormat*$02)
			RTL
	
		..TwoDigits
			JSL $00974C|!bank							;>HexDec (A = 1s, X = 10s).
			STA !Settings_MBCM16_KeyCounterTileNumbPos+(!StatusbarFormat*$03)	;>Ones
			TXA									;\Tens
			STA !Settings_MBCM16_KeyCounterTileNumbPos+(!StatusbarFormat*$02)	;/
	.Done
		RTL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;What key counter to use depending on what level you're in.
;
;Similarly to MBCM16WriteGroup128To7FC060.asm, but instead
;of what group-128, it is what key counter to use. Each nth
;item here represents what level to use, example:
;
;
;.LevelList
;	dw $0105		;>N = 1
;	dw $0106		;>N = 2
;	..End
;.WhatKeyCounterIndex
;	db $00			;>N = 1
;	db $01			;>N = 2
;	..End
;Means that level $0105 to use key counter index 0
;and level $0106 to use index 1.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.LevelList
	dw $0105
	..End
.WhatKeyCounterIndex
	db $00
	..End