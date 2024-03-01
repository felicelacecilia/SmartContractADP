// SPDX-License-Identifier: UNLICENSE

pragma solidity ^0.8.9;

//L'uso di questa libreria permette di stampare a schermo le informazioni contenute nelle variabili
import "hardhat/console.sol";

contract ViaggioMerci {
    // Struttura dati contenente le informazioni di volo
    struct Viaggio {
        uint codiceVolo;
        string compagniaAerea;
        uint pesoAereo;
        string puntoPartenza;
        string puntoDestinazione;
        uint tempoHangar;
        uint prezzoViaggio;
        bool pagato;
        bool concessione;
        bool assistenza;
    }

    // Mappa per associare il codice del volo al viaggio
    mapping(uint => Viaggio) public viaggi;

    // Indirizzo del destinatario dei pagamenti
    address payable public destinatarioPagamenti;

    // Evento emesso al momento del pagamento
    event PagamentoEffettuato(address pagatore, uint importo);

    // Costruttore
    constructor(uint _codiceVolo, string memory _compagniaAerea, uint _pesoAereo, string memory _puntoPartenza, string memory _puntoDestinazione, uint _tempoHangar, bool _assistenza) {
        
        // Calcolo del prezzo
        uint _prezzo = calcolaPrezzo(_pesoAereo, _tempoHangar, _assistenza);

        bool _pagato = false;
        bool _concessione = false;
        
        //Salvataggio del volo
        viaggi[_codiceVolo] = Viaggio(_codiceVolo, _compagniaAerea, _pesoAereo, _puntoPartenza, _puntoDestinazione, _tempoHangar, _prezzo, _pagato, _concessione, _assistenza);

        // Imposta l'indirizzo del destinatario dei pagamenti
        destinatarioPagamenti = payable(0x54EE772D8B46929a3579b10DC90f4D7B78e3Fb9D);
    }

    // Funzione per calcolare il prezzo in base ai parametri come il peso e il tempo di permanenza
    function calcolaPrezzo(uint _pesoAereo, uint _tempoHangar, bool _assistenza) internal pure returns (uint) {
        uint prezzo = 0;

        //Tassa di atterraggio e decollo in base al peso dell'aereo
        if(_pesoAereo <= 25)
            prezzo = (100000*_pesoAereo);
        else
            prezzo = (152000*_pesoAereo);

        if(_assistenza)
            prezzo += 5527915;
        
        //Tassa di stazionamento, tassa per sbarco e imbarco merci, e quella relativa alle infrastrutture aeroportuali e alla sicurezza e al smaltimento rifiuti
        prezzo += (13000 * _tempoHangar) + (507 * _pesoAereo) + (10350000 + 4110000 + 1014000  + 1300000);

        return prezzo;
    }

    // Funzione per effettuare un pagamento verso l'indirizzo del destinatario dei pagamenti
    function effettuaPagamento(uint _codiceVolo) public payable {
        require(msg.value >= viaggi[_codiceVolo].prezzoViaggio, "Importo del pagamento non corrispondente al prezzo del viaggio");
        
        // Trasferisce l'importo pagato all'indirizzo del destinatario dei pagamenti
        destinatarioPagamenti.transfer(msg.value);
        
        // Emette l'evento per segnalare il pagamento effettuato
        emit PagamentoEffettuato(msg.sender, msg.value);

        viaggi[_codiceVolo].pagato = true;

        console.log("Pagamento effettuato con successo!");
    }

    function concessioneVolo(uint _codiceVolo) public {
        require( viaggi[_codiceVolo].pagato, "Concessione di volo rifiutata!");

        viaggi[_codiceVolo].concessione = true;

        console.log("Autorizzazione di volo accettata!");
    }

    // Funzione per richiedere un rimborso per un viaggio cancellato
    function richiediRimborso(uint256 _codiceVolo) public {
        require(viaggi[_codiceVolo].assistenza, "Non hai diritto al rimborso!");

        // Trasferisce il prezzo del viaggio al richiedente
        payable(msg.sender).transfer(viaggi[_codiceVolo].prezzoViaggio);

        // Segna il viaggio come non pagato
        viaggi[_codiceVolo].pagato = false;
    }


    //Mostra a schermo tutte le informazioni del volo
    function mostraVolo(uint _codiceVolo) public view{
        console.log("Codice Volo: ", viaggi[_codiceVolo].codiceVolo);
        console.log("Compagnia Aerea: ", viaggi[_codiceVolo].compagniaAerea);
        console.log("Peso Aereo: ", viaggi[_codiceVolo].pesoAereo);
        console.log("Partenza: ", viaggi[_codiceVolo].puntoPartenza);
        console.log("Destinazione: ", viaggi[_codiceVolo].puntoDestinazione);
        console.log("Tempo Hangar: ", viaggi[_codiceVolo].tempoHangar);
        console.log("Prezzo: ", viaggi[_codiceVolo].prezzoViaggio);
    }
}
