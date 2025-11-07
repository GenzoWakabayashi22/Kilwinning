import XCTest
@testable import KilwinningApp

final class NetworkServiceTests: XCTestCase {
    
    // MARK: - DTO Decoding Tests
    
    func testTornataDTODecoding() throws {
        let json = """
        {
            "id": 1,
            "titolo": "Il sentiero della saggezza",
            "data_tornata": "2025-11-25T19:30:00Z",
            "tipo": "Ordinaria",
            "luogo": "Nostra Loggia - Tolfa",
            "presentato_da": "Fr. Marco Rossi",
            "ha_agape": 1,
            "note": "Note di esempio"
        }
        """
        
        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let dto = try decoder.decode(TornataDTO.self, from: data)
        
        XCTAssertEqual(dto.id, 1)
        XCTAssertEqual(dto.titolo, "Il sentiero della saggezza")
        XCTAssertEqual(dto.tipo, "Ordinaria")
        XCTAssertEqual(dto.luogo, "Nostra Loggia - Tolfa")
        XCTAssertEqual(dto.presentato_da, "Fr. Marco Rossi")
        XCTAssertEqual(dto.ha_agape, 1)
        XCTAssertEqual(dto.note, "Note di esempio")
    }
    
    func testPresenzaDTODecoding() throws {
        let json = """
        {
            "id": 1,
            "id_fratello": 5,
            "id_tornata": 10,
            "stato": "Presente",
            "confermato_il": "2025-11-20T10:00:00Z"
        }
        """
        
        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let dto = try decoder.decode(PresenzaDTO.self, from: data)
        
        XCTAssertEqual(dto.id, 1)
        XCTAssertEqual(dto.id_fratello, 5)
        XCTAssertEqual(dto.id_tornata, 10)
        XCTAssertEqual(dto.stato, "Presente")
        XCTAssertNotNil(dto.confermato_il)
    }
    
    func testLibroDTODecoding() throws {
        let json = """
        {
            "id": 1,
            "titolo": "Il Simbolismo Massonico",
            "autore": "Jules Boucher",
            "anno": "1948",
            "categoria": "Simbologia",
            "codice_archivio": "SIM-001",
            "stato": "Disponibile",
            "copertina_url": "https://example.com/cover.jpg"
        }
        """
        
        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        
        let dto = try decoder.decode(LibroDTO.self, from: data)
        
        XCTAssertEqual(dto.id, 1)
        XCTAssertEqual(dto.titolo, "Il Simbolismo Massonico")
        XCTAssertEqual(dto.autore, "Jules Boucher")
        XCTAssertEqual(dto.anno, "1948")
        XCTAssertEqual(dto.categoria, "Simbologia")
        XCTAssertEqual(dto.codice_archivio, "SIM-001")
        XCTAssertEqual(dto.stato, "Disponibile")
        XCTAssertEqual(dto.copertina_url, "https://example.com/cover.jpg")
    }
    
    func testPrestitoDTODecoding() throws {
        let json = """
        {
            "id": 1,
            "id_libro": 3,
            "id_fratello": 5,
            "data_prestito": "2025-11-01T00:00:00Z",
            "data_restituzione": null,
            "data_scadenza": "2025-12-01T00:00:00Z",
            "stato_prestito": "Attivo"
        }
        """
        
        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        
        let dto = try decoder.decode(PrestitoDTO.self, from: data)
        
        XCTAssertEqual(dto.id, 1)
        XCTAssertEqual(dto.id_libro, 3)
        XCTAssertEqual(dto.id_fratello, 5)
        XCTAssertEqual(dto.stato_prestito, "Attivo")
        XCTAssertNil(dto.data_restituzione)
    }
    
    func testAudioDiscussioneDTODecoding() throws {
        let json = """
        {
            "id": 1,
            "id_tornata": 5,
            "fratello_intervento": "Fr. Marco Rossi",
            "titolo_intervento": "Riflessioni sul simbolismo",
            "durata": "12:45",
            "audio_url": "https://pcloud.com/audio.mp3",
            "data_upload": "2025-11-20T15:00:00Z"
        }
        """
        
        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        
        let dto = try decoder.decode(AudioDiscussioneDTO.self, from: data)
        
        XCTAssertEqual(dto.id, 1)
        XCTAssertEqual(dto.id_tornata, 5)
        XCTAssertEqual(dto.fratello_intervento, "Fr. Marco Rossi")
        XCTAssertEqual(dto.titolo_intervento, "Riflessioni sul simbolismo")
        XCTAssertEqual(dto.durata, "12:45")
        XCTAssertEqual(dto.audio_url, "https://pcloud.com/audio.mp3")
    }
    
    func testChatRoomDTODecoding() throws {
        let json = """
        {
            "id": 1,
            "nome_chat": "Loggia Kilwinning",
            "descrizione": "Chat principale della loggia",
            "data_creazione": "2025-01-01T00:00:00Z",
            "total_messages": 42,
            "ultimo_messaggio": "2025-11-20T10:00:00Z"
        }
        """
        
        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        
        let dto = try decoder.decode(ChatRoomDTO.self, from: data)
        
        XCTAssertEqual(dto.id, 1)
        XCTAssertEqual(dto.nome_chat, "Loggia Kilwinning")
        XCTAssertEqual(dto.descrizione, "Chat principale della loggia")
        XCTAssertEqual(dto.total_messages, 42)
    }
    
    func testChatMessageDTODecoding() throws {
        let json = """
        {
            "id": 1,
            "id_chat": 1,
            "id_mittente": 5,
            "testo": "Fratelli, ricordo la prossima tornata",
            "data_invio": "2025-11-20T10:00:00Z",
            "letto": 1,
            "mittente_nome": "Marco",
            "mittente_cognome": "Rossi"
        }
        """
        
        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        
        let dto = try decoder.decode(ChatMessageDTO.self, from: data)
        
        XCTAssertEqual(dto.id, 1)
        XCTAssertEqual(dto.id_chat, 1)
        XCTAssertEqual(dto.id_mittente, 5)
        XCTAssertEqual(dto.testo, "Fratelli, ricordo la prossima tornata")
        XCTAssertEqual(dto.letto, 1)
        XCTAssertEqual(dto.mittente_nome, "Marco")
        XCTAssertEqual(dto.mittente_cognome, "Rossi")
    }
    
    // MARK: - API Response Tests
    
    func testAPIResponseDecoding() throws {
        let json = """
        {
            "success": true,
            "data": [
                {
                    "id": 1,
                    "titolo": "Test Libro",
                    "autore": "Test Autore",
                    "anno": "2024",
                    "categoria": "Test",
                    "codice_archivio": "TST-001",
                    "stato": "Disponibile",
                    "copertina_url": null
                }
            ]
        }
        """
        
        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        
        let response = try decoder.decode(APIResponse<[LibroDTO]>.self, from: data)
        
        XCTAssertTrue(response.success)
        XCTAssertEqual(response.data.count, 1)
        XCTAssertEqual(response.data[0].titolo, "Test Libro")
    }
    
    func testAPISuccessResponseDecoding() throws {
        let json = """
        {
            "success": true,
            "message": "Operation completed successfully",
            "id": 42
        }
        """
        
        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        
        let response = try decoder.decode(APISuccessResponse.self, from: data)
        
        XCTAssertTrue(response.success)
        XCTAssertEqual(response.message, "Operation completed successfully")
        XCTAssertEqual(response.id, 42)
    }
    
    // MARK: - Request Encoding Tests
    
    func testUpdatePresenzaRequestEncoding() throws {
        let request = UpdatePresenzaRequest(
            id_fratello: 5,
            id_tornata: 10,
            stato: "Presente"
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(request)
        let json = String(data: data, encoding: .utf8)!
        
        XCTAssertTrue(json.contains("\"id_fratello\":5"))
        XCTAssertTrue(json.contains("\"id_tornata\":10"))
        XCTAssertTrue(json.contains("\"stato\":\"Presente\""))
    }
    
    func testCreatePrestitoRequestEncoding() throws {
        let request = CreatePrestitoRequest(
            id_libro: 3,
            id_fratello: 5
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(request)
        let json = String(data: data, encoding: .utf8)!
        
        XCTAssertTrue(json.contains("\"id_libro\":3"))
        XCTAssertTrue(json.contains("\"id_fratello\":5"))
    }
}
