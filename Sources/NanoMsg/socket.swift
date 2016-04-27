import cnanomsg
import C7


public enum DomainTypes {
	case af
}

public enum SocketTypes {
	case pair, req, rep, pub, sub, surveyor, respondent, push, pull, bus

	var rawValue: Int32 {
		switch self {
			case pair: return NN_PAIR
			case req: return NN_REQ
			case rep: return NN_REP
			case pub: return NN_PUB
			case sub: return NN_SUB
			case surveyor: return NN_SURVEYOR
			case respondent: return NN_RESPONDENT
			case push: return NN_PUSH
			case pull: return NN_PULL
			case bus: return NN_BUS
		}
	}
}

public enum SocketErrors: ErrorProtocol {
	case asd
}

public final class Socket {
	let socket: Int32
	var endpointId: Int32? = nil
	public init(type: SocketTypes) throws {
		socket = nn_socket(AF_SP, type.rawValue)
		if socket < 0 {
			throw SocketErrors.asd
		}
	}
	deinit {
		nn_close(socket)
	}
	public func shutdown() {
		guard let eid = endpointId else { return }
		nn_shutdown(socket, eid)
	}
	public func bind(_ address: String) throws {
		shutdown()
		let res = nn_bind(socket ,address)
		if res >= 0 {
			endpointId = res
        } else {
            throw SocketErrors.asd
        }
	}
	public func connect(_ address: String) throws {
		shutdown()
		let res = nn_connect(socket, address)
		if res >= 0 {
			endpointId = res
            } else {
                throw SocketErrors.asd
            }
	}
    public func send(_ data: Data) {
        var data = data
        let count = nn_send(socket, &data.bytes, data.count, 0)
        print("sent, \(count)")
	}
    public func receive() -> Data {
//        let bufferSize = 1024
        var buffer = UnsafeMutablePointer<Byte>(allocatingCapacity: 0)
        print("before recv")
        let count = nn_recv(socket, &buffer, -1, 0)
        print("after recv")
        let bytes: [Byte] = Array(UnsafeMutableBufferPointer(start: buffer, count: Int(count)))
        nn_freemsg(buffer)
        return Data(bytes)
    }

	static public func device(s1: Socket, s2: Socket) {

	}
	
	public func setOption() {

	}

}