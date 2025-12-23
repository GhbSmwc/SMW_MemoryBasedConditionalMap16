	incsrc "../MBCM16Defines/Defines.asm"
;>bytes 1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;This uberASM tool level code does 2 things
; - Calls a subroutine that would transfer !Freeram_MBCM16_MemoryFlag to $7FC060 during level load
; - Display a key counter on the layer 3 status bar, with which counter to show being the extra byte.
;Extra bytes info:
; EXB1: Key counter index to use.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
load:
	JSL MBCM16WriteGroup128To7FC060_LoadFlagTableToCM16
	RTL
main:
init:
DisplayHud:
	.GetExtraByteForKeyCounterIndex
		LDA ($00)
		TAY
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