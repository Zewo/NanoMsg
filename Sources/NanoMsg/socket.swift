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
}
extension Socket {

    public func setOption(_ level: Int32, _ option: Int32, _ value: Int32) throws {
        var value = value
        nn_setsockopt(socket, level, option, &value, strideof(Int32))
	}
    public func setOption(_ level: Int32, _ option: Int32, _ value: Data) throws {
        nn_setsockopt(socket, level, option, value.bytes, value.count)
    }
    public func setOption(_ level: Int32, _ option: Int32, _ value: Bool) throws {
        let value: Int32 = (value) ? 1 : 0
        try setOption(level, option, value)
    }
    public func setOption(_ level: Int32, _ option: Int32, _ value: String) throws {
        try setOption(level, option, Data(value))
    }
}

extension Socket {
    
}


extension Socket {
    func setLinger(_ value: Int32) throws {
        try setOption(NN_SOL_SOCKET, NN_LINGER, value)
    }
    func setSendBuffer(_ value: Int32) throws {
        try setOption(NN_SOL_SOCKET, NN_SNDBUF, value)
    }
    func setReceiveBuffer(_ value: Int32) throws {
        try setOption(NN_SOL_SOCKET, NN_RCVBUF, value)
    }
    func setReceiveMaxSize(_ value: Int32) throws {
        try setOption(NN_SOL_SOCKET, NN_RCVMAXSIZE, value)
    }
    func setSendTimeout(_ value: Int32) throws {
        try setOption(NN_SOL_SOCKET, NN_SNDTIMEO, value)
    }
    func setReceiveTimeout(_ value: Int32) throws {
        try setOption(NN_SOL_SOCKET, NN_RCVTIMEO, value)
    }
    func setReconnectInterval(_ value: Int32) throws {
        try setOption(NN_SOL_SOCKET, NN_RECONNECT_IVL, value)
    }
    func setMaxReconnectInterval(_ value: Int32) throws {
        try setOption(NN_SOL_SOCKET, NN_RECONNECT_IVL_MAX, value)
    }
    func setSendPrority(_ value: Int32) throws {
        try setOption(NN_SOL_SOCKET, NN_SNDPRIO, value)
    }
    func setReceivePrioriry(_ value: Int32) throws {
        try setOption(NN_SOL_SOCKET, NN_RCVPRIO, value)
    }
    func setIPV4Only(_ value: Bool) throws {
        try setOption(NN_SOL_SOCKET, NN_IPV4ONLY, value)
    }
    func setSocketName(_ value: String) throws {
        try setOption(NN_SOL_SOCKET, NN_SOCKET_NAME, value)
    }
    
}

public enum WebSocketMessageType {
    case text, binary
    var rawValue: Int32 {
        switch self {
        case .text: return NN_WS_MSG_TYPE_TEXT
        case .binary: return NN_WS_MSG_TYPE_BINARY
        }
    }
}

extension Socket {
    func setRequestResendInterval(_ value: Int32) throws {
        try setOption(NN_REQ, NN_REQ_RESEND_IVL, value) //get
    }
    
    func setSubscribe(_ value: Data) throws {
        try setOption(NN_SUB, NN_SUB_SUBSCRIBE, value)
    }
    func setUnsubscribe(_ value: Data) throws {
        try setOption(NN_SUB, NN_SUB_UNSUBSCRIBE, value)
    }
    
    func setSurveyorDeadline(_ value: Int32) throws {
        try setOption(NN_SURVEYOR, NN_SURVEYOR_DEADLINE, value)
    }
    
    func setTcpNoDelay(_ value: Bool) throws {
        try setOption(NN_TCP, NN_TCP_NODELAY, value)
    }
    
    func setWsMsgType(_ value: WebSocketMessageType) throws {
        try setOption(NN_WS, NN_WS_MSG_TYPE, value.rawValue)
    }
    
}
