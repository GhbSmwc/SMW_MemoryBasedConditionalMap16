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
	;(note to developer, place code that loads a level number and determine what Y index/key counter to use)
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
	