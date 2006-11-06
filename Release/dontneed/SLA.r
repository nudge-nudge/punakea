data 'LPic' (5000) {
    $"0002 0011 0003 0001 0000 0000 0002 0000"
    $"0008 0003 0000 0001 0004 0000 0004 0005"
    $"0000 000E 0006 0001 0005 0007 0000 0007"
    $"0008 0000 0047 0009 0000 0034 000A 0001"
    $"0035 000B 0001 0020 000C 0000 0011 000D"
    $"0000 005B 0004 0000 0033 000F 0001 000C"
    $"0010 0000 000B 000E 0000"
};


data 'TEXT' (5002, "English") {
    "Copyright (c) 2006 nudge:nudge. All rights reserved.\n"
    "\n"
	"This is experimental software and may have bugs, some of which may have "
	"serious consequences.\n"
	"\n"
	"THERE IS NO WARRANTY FOR THE PROGRAM, TO THE EXTENT PERMITTED BY "
	"APPLICABLE LAW.\n"
	"IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING "
	"WILL ANY COPYRIGHT HOLDER BE LIABLE TO YOU FOR DAMAGES, INCLUDING ANY "
	"GENERAL, SPECIAL, INCIDENTAL OR CONSEQUENTIAL DAMAGES ARISING OUT OF "
	"THE USE OR INABILITY TO USE THE PROGRAM (INCLUDING BUT NOT LIMITED TO "
	"LOSS OF DATA OR DATA BEING RENDERED INACCURATE OR LOSSES SUSTAINED BY "
	"YOU OR THIRD PARTIES OR A FAILURE OF THE PROGRAM TO OPERATE WITH ANY "
	"OTHER PROGRAMS), EVEN IF SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED "
	"OF THE POSSIBILITY OF SUCH DAMAGES.\n"
    "\n"
    "For the most recent version see <http://www.nudgenudge.eu>\n"
};


resource 'STR#' (5001, "German") {
    {   /* array StringArray: 9 elements */
        /* [1] */
        "Deutsch",
        /* [2] */
        "Akzeptieren",
        /* [3] */
        "Ablehnen",
        /* [4] */
        "Drucken",
        /* [5] */
        "Sichern...",
        /* [6] */
        "Klicken Sie auf “Akzeptieren”, wenn Sie mit den Bestimmungen des "
        "Software-Lizenzvertrages einverstanden sind. Falls nicht, klicken "
        "Sie bitte “Ablehnen” an. Sie können die Software nur installieren, "
        "wenn Sie “Akzeptieren” angeklickt haben.",
        /* [7] */
        "Software-Lizenzvertrag",
        /* [8] */
        "Dieser Text kann nicht gesichert werden. Diese Festplatte ist "
        "möglicherweise voll oder geschützt oder der Ordner ist geschützt.",
        /* [9] */
        "Es kann nicht gedruckt werden. Bitte stellen Sie sicher, daß ein "
        "Drucker ausgewählt ist."
    }
};

resource 'STR#' (5002, "English") {
    {   /* array StringArray: 9 elements */
        /* [1] */
        "English",
        /* [2] */
        "Agree",
        /* [3] */
        "Disagree",
        /* [4] */
        "Print",
        /* [5] */
        "Save...",
        /* [6] */
        "IMPORTANT - Read this License Agreement carefully before clicking on "
        "the \"Agree\" button.  By clicking on the \"Agree\" button, you agree "
        "to be bound by the terms of the License Agreement.",
        /* [7] */
        "Software License Agreement",
        /* [8] */
        "This text cannot be saved. This disk may be full or locked, or the file "
        "may be locked.",
        /* [9] */
        "Unable to print. Make sure you’ve selected a printer."
    }
};

resource 'STR#' (5003, "Spanish") {
    {   /* array StringArray: 9 elements */
        /* [1] */
        "Español",
        /* [2] */
        "Aceptar",
        /* [3] */
        "No aceptar",
        /* [4] */
        "Imprimir",
        /* [5] */
        "Guardar...",
        /* [6] */
        "Si está de acuerdo con los términos de esta licencia, pulse \"Aceptar\" "
        "para instalar el software. En el supuesto de que no esté de acuerdo con "
        "los términos de esta licencia, pulse \"No aceptar.\"",
        /* [7] */
        "Licencia de Software",
        /* [8] */
        "Este texto no se puede guardar. El disco puede estar lleno o bloqueado, "
        "o el archivo puede estar bloqueado.",
        /* [9] */
        "No se puede imprimir. Compruebe que ha seleccionado una impresora."
    }
};

resource 'STR#' (5004, "French") {
    {   /* array StringArray: 9 elements */
        /* [1] */
        "Français",
        /* [2] */
        "Accepter",
        /* [3] */
        "Refuser",
        /* [4] */
        "Imprimer",
        /* [5] */
        "Enregistrer...",
        /* [6] */
        "Si vous acceptez les termes de la présente licence, cliquez sur "
        "\"Accepter\" afin d'installer le logiciel. Si vous n'êtes pas d'accord "
        "avec les termes de la licence, cliquez sur \"Refuser\".",
        /* [7] */
        "Contrat de licence de logiciel",
        /* [8] */
        "Ce texte ne peut être sauvegardé. Le disque est peut-être saturé ou "
        "verrouillé, ou bien le fichier est peut-être verrouillé.",
        /* [9] */
        "Impression impossible. Assurez-vous d’avoir sélectionné une imprimante."
    }
};

resource 'STR#' (5005, "Italian") {
    {    /* array StringArray: 9 elements */
        /* [1] */
        "Italiano",
        /* [2] */
        "Accetto",
        /* [3] */
        "Rifiuto",
        /* [4] */
        "Stampa",
        /* [5] */
        "Registra...",
        /* [6] */
        "Se accetti le condizioni di questa licenza, fai clic su \"Accetto\" per "
        "installare il software. Altrimenti fai clic su \"Rifiuto\".",
        /* [7] */
        "Licenza Software",
        /* [8] */
        "Non posso registrare il testo. Il disco potrebbe essere pieno o protetto "
        "oppure il documento potrebbe essere protetto.",
        /* [9] */
        "Non posso stampare. Assicurati di aver selezionato una stampante."
    }
};



resource 'STR#' (5007, "Dutch") {
    {   /* array StringArray: 9 elements */
        /* [1] */
        "Nederlands",
        /* [2] */
        "Ja",
        /* [3] */
        "Nee",
        /* [4] */
        "Print",
        /* [5] */
        "Bewaar...",
        /* [6] */
        "Indien u akkoord gaat met de voorwaarden van deze licentie, kunt u op 'Ja' "
        "klikken om de programmatuur te installeren. Indien u niet akkoord gaat, "
        "klikt u op 'Nee'.",
        /* [7] */
        "Softwarelicentie",
        /* [8] */
        "De tekst kan niet worden bewaard. Het kan zijn dat uw schijf vol of "
        "beveiligd is of dat het bestand beveiligd is.",
        /* [9] */
        "Afdrukken niet mogelijk. Zorg dat er een printer is geselecteerd."
    }
};

resource 'STR#' (5008, "Swedish") {
    {   /* array StringArray: 9 elements */
        /* [1] */
        "Svensk",
        /* [2] */
        "Godkänns",
        /* [3] */
        "Avböjs",
        /* [4] */
        "Skriv ut",
        /* [5] */
        "Spara...",
        /* [6] */
        "Om Du godkänner licensvillkoren klicka på \"Godkänns\" för att installera "
        "programprodukten. Om Du inte godkänner licensvillkoren, klicka på \"Avböjs\".",
        /* [7] */
        "Licensavtal för Programprodukt",
        /* [8] */
        "Den här texten kan inte sparas eftersom antingen skivan är full eller skivan "
        "och/eller dokumentet är låst.",
        /* [9] */
        "Kan inte skriva ut. Kontrollera att du har valt en skrivare. "
    }
};

resource 'STR#' (5009, "Brazilian Portuguese") {
    {   /* array StringArray: 9 elements */
        /* [1] */
        "Português, Brasil",
        /* [2] */
        "Concordar",
        /* [3] */
        "Discordar",
        /* [4] */
        "Imprimir",
        /* [5] */
        "Salvar...",
        /* [6] */
        "Se está de acordo com os termos desta licença, pressione \"Concordar\" para "
        "instalar o software. Se não está de acordo, pressione \"Discordar\".",
        /* [7] */
        "Licença de Uso de Software",
        /* [8] */
        "Este texto não pode ser salvo. O disco pode estar cheio ou\nbloqueado, ou o "
        "arquivo pode estar bloqueado.",
        /* [9] */
        "Não é possível imprimir. Comprove que você selecionou uma impressora."
    }
};

resource 'STR#' (5010, "Simplified Chinese") {
    {   /* array StringArray: 9 elements */
        /* [1] */
        "Simplified Chinese",
        /* [2] */
        "Õ¨“‚",
        /* [3] */
        "≤ªÕ¨“‚",
        /* [4] */
        "¥Ú”°",
        /* [5] */
        "¥Ê¥¢°≠",
        /* [6] */
        "»Áπ˚ƒ˙Õ¨“‚±æ–Ìø…–≠“ÈµƒÃıøÓ£¨«Î∞¥°∞Õ¨“‚°±"
        "¿¥∞≤◊∞¥À»Ìº˛°£»Áπ˚ƒ˙≤ªÕ¨“‚£¨«Î∞¥°∞≤ªÕ¨“‚"
        "°±°£",
        /* [7] */
        "»Ìº˛–Ìø…–≠“È",
        /* [8] */
        "≤ªƒ‹¥Ê¥¢’‚∏ˆŒƒº˛°£¥≈≈Ãø…ƒ‹±ªÀ¯∂®ªÚ“—¬˙£¨"
        "“≤–Ì «Œƒº˛±ªÀ¯∂®¡À°£",
        /* [9] */
        "Œﬁ∑®¥Ú”°°£«Î»∑∂®ƒ˙“——°‘Ò¡À“ªÃ®¥Ú”°ª˙°£"
    }
};

resource 'STR#' (5011, "Traditional Chinese") {
    {   /* array StringArray: 9 elements */
        /* [1] */
        "Traditional Chinese",
        /* [2] */
        "¶P∑N",
        /* [3] */
        "§£¶P∑N",
        /* [4] */
        "¶C¶L",
        /* [5] */
        "¿x¶s°K",
        /* [6] */
        "¶p™G±z¶P∑N•ª≥\\•i√“∏Ã™∫±¯¥⁄°AΩ–´ˆ°ß¶P∑N°®"
        "•H¶w∏À≥n≈È°C¶p™G§£¶P∑N°AΩ–´ˆ°ß§£¶P∑N°®°C",
        /* [7] */
        "≥n≈È≥\\•i®Ûƒ≥",
        /* [8] */
        "•ª§Â¶rµL™k¿x¶s°C≥o≠”∫œ∫–•iØ‡§w∫°©Œ¨O¬Í©w"
        "°A©Œ¿…Æ◊§w∏g¬Í©w°C",
        /* [9] */
        "µL™k¶C¶L°CΩ–ΩT©w±z§w∏gøÔæ‹§F¶L™Ìæ˜°C"
    }
};

resource 'STR#' (5012, "Danish") {
    {   /* array StringArray: 9 elements */
        /* [1] */
        "Dansk",
        /* [2] */
        "Enig",
        /* [3] */
        "Uenig",
        /* [4] */
        "Udskriv",
        /* [5] */
        "Arkiver...",
        /* [6] */
        "Hvis du accepterer betingelserne i licensaftalen, skal du klikke på “Enig” "
        "for at installere softwaren. Klik på “Uenig” for at annullere installeringen.",
        /* [7] */
        "Licensaftale for software",
        /* [8] */
        "Teksten kan ikke arkiveres. Disken er evt. fuld eller låst, eller også er "
        "arkivet låst.",
        /* [9] */
        "Kan ikke udskrive. Sørg for, at der er valgt en printer."
    }
};

resource 'STR#' (5013, "Finnish") {
    {   /* array StringArray: 9 elements */
        /* [1] */
        "Suomi",
        /* [2] */
        "Hyväksyn",
        /* [3] */
        "En hyväksy",
        /* [4] */
        "Tulosta",
        /* [5] */
        "Tallenna…",
        /* [6] */
        "Hyväksy lisenssisopimuksen ehdot osoittamalla ’Hyväksy’. Jos et hyväksy "
        "sopimuksen ehtoja, osoita ’En hyväksy’.",
        /* [7] */
        "Lisenssisopimus",
        /* [8] */
        "Tekstiä ei voida tallentaa. Levy voi olla täynnä tai lukittu.",
        /* [9] */
        "Tekstiä ei voida tulostaa. Varmista, että kirjoitin on valittu."
    }
};

resource 'STR#' (5014, "French Canadian") {
    {   /* array StringArray: 9 elements */
        /* [1] */
        "Français canadien",
        /* [2] */
        "Accepter",
        /* [3] */
        "Refuser",
        /* [4] */
        "Imprimer",
        /* [5] */
        "Enregistrer...",
        /* [6] */
        "Si vous acceptez les termes de la présente licence, cliquez sur \"Accepter\" "
        "afin d'installer le logiciel. Si vous n'êtes pas d'accord avec les termes de "
        "la licence, cliquez sur \"Refuser\".",
        /* [7] */
        "Contrat de licence de logiciel",
        /* [8] */
        "Ce texte ne peut être sauvegardé. Le disque est peut-être saturé ou verrouillé, "
        "ou bien le fichier est peut-être verrouillé.",
        /* [9] */
        "Impression impossible. Assurez-vous d’avoir sélectionné une imprimante."
    }
};

resource 'STR#' (5015, "Korean") {
    {   /* array StringArray: 9 elements */
        /* [1] */
        "Korean",
        /* [2] */
        "µø¿«",
        /* [3] */
        "µø¿« æ»«‘",
        /* [4] */
        "«¡∏∞∆Æ",
        /* [5] */
        "¿˙¿Â...",
        /* [6] */
        "ªÁøÎ ∞Ëæ‡º≠¿« ≥ªøÎø° µø¿««œ∏È, \"µø¿«\" ¥‹"
        "√ﬂ∏¶ ¥≠∑Ø º“«¡∆Æø˛æÓ∏¶ º≥ƒ°«œΩ Ω√ø¿. µø¿"
        "««œ¡ˆ æ ¥¬¥Ÿ∏È, \"µø¿« æ»«‘\" ¥‹√ﬂ∏¶ ¥©∏£Ω"
        " Ω√ø¿.",
        /* [7] */
        "ªÁøÎ ∞Ëæ‡ µø¿«º≠",
        /* [8] */
        "¿Ã ≈ÿΩ∫∆Æ∏¶ ¿˙¿Â«“ ºˆ æ¯Ω¿¥œ¥Ÿ. ¿Ã µΩ∫≈"
        "©¥¬ ≤À √°∞≈≥™ ¿·∞‹ ¿÷Ω¿¥œ¥Ÿ. ∂«¥¬ ∆ƒ¿œ¿Ã"
        " ¿·∞‹ ¿÷¿ª ºˆµµ ¿÷Ω¿¥œ¥Ÿ.",
        /* [9] */
        "«¡∏∞∆Æ«“ ºˆ æ¯Ω¿¥œ¥Ÿ. «¡∏∞≈Õ∏¶ º±≈√«ﬂ¥¬¡"
        "ˆ »Æ¿Œ«œΩ Ω√ø¿."
    }
};

resource 'STR#' (5016, "Norwegian") {
    {   /* array StringArray: 9 elements */
        /* [1] */
        "Norsk",
        /* [2] */
        "Enig",
        /* [3] */
        "Ikke enig",
        /* [4] */
        "Skriv ut",
        /* [5] */
        "Arkiver...",
        /* [6] */
        "Hvis De er enig i bestemmelsene i denne lisensavtalen, klikker De på "
        "\"Enig\"-knappen for å installere programvaren. Hvis De ikke er enig, "
        "klikker De på \"Ikke enig\".",
        /* [7] */
        "Programvarelisensavtale",
        /* [8] */
        "Denne teksten kan ikke arkiveres. Disken kan være full eller låst, "
        "eller filen kan være låst. ",
        /* [9] */
        "Kan ikke skrive ut. Forsikre deg om at du har valgt en skriver. "
    }
};
