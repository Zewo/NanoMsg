import cnanomsg
import C7

let NN_MSG: size_t = -1

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
        var buffer = UnsafeMutablePointer<Byte>(allocatingCapacity: 0)
        let count = nn_recv(socket, &buffer, NN_MSG, 0)
        let bytes: [Byte] = Array(UnsafeMutableBufferPointer(start: buffer, count: Int(count)))
        nn_freemsg(buffer)
        return Data(bytes)
    }

	static public func device(s1: Socket, s2: Socket) {

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

extension Socket {
    func setRequestResendInterval(_ value: Int32) throws {
        try setOption(NN_REQ, NN_REQ_RESEND_IVL, value)
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

extension Socket {
    func getOption(_ level: Int32, _ option: Int32) throws -> Int32 {
        var v: Int32 = 0
        var size = strideof(Int32)
        nn_getsockopt(socket, level, option, &v, &size)
        return v
    }
    func getOption(_ level: Int32, _ option: Int32) throws -> Bool {
        let val: Int32 = try getOption(level, option)
        return (val == 1) ? true : false
    }
    func getOption(_ level: Int32, _ option: Int32) throws -> Data {
        var buffLength = 256
        var buff = Data.buffer(with: buffLength)
        nn_getsockopt(socket, level, option, &buff.bytes, &buffLength)
        return buff
    }
    func getOption(_ level: Int32, _ option: Int32) throws -> String {
        let data: Data = try getOption(level, option)
        return String(data)
    }
}

extension Socket {
    func getDomain() throws -> Int32 {
        return try getOption(NN_SOL_SOCKET, NN_DOMAIN)
    }
    func getProtocol() throws -> Int32 {
        return try getOption(NN_SOL_SOCKET, NN_PROTOCOL)
    }
    func getLinger() throws -> Int32 {
        return try getOption(NN_SOL_SOCKET, NN_LINGER)
    }
    func getSendBuffer() throws -> Int32 {
        return try getOption(NN_SOL_SOCKET, NN_SNDBUF)
    }
    func getReceiveBuffer() throws -> Int32 {
        return try getOption(NN_SOL_SOCKET, NN_RCVBUF)
    }
    func getReceiveMaxSize() throws -> Int32 {
        return try getOption(NN_SOL_SOCKET, NN_RCVMAXSIZE)
    }
    func getSendTimeout() throws -> Int32 {
        return try getOption(NN_SOL_SOCKET, NN_SNDTIMEO)
    }
    func getReceiveTimeout() throws -> Int32 {
        return try getOption(NN_SOL_SOCKET, NN_RCVTIMEO)
    }
    func getReconnectInterval() throws -> Int32 {
        return try getOption(NN_SOL_SOCKET, NN_RECONNECT_IVL)
    }
    func getMaxReconnectInterval() throws -> Int32 {
        return try getOption(NN_SOL_SOCKET, NN_RECONNECT_IVL_MAX)
    }
    func getSendPriority() throws -> Int32 {
        return try getOption(NN_SOL_SOCKET, NN_SNDPRIO)
    }
    func getReceivePriority() throws -> Int32 {
        return try getOption(NN_SOL_SOCKET, NN_RCVPRIO)
    }
    func getIPV4Only() throws -> Bool {
        return try getOption(NN_SOL_SOCKET, NN_IPV4ONLY)
    }
    func getSendFD() throws -> Int32 {
        return try getOption(NN_SOL_SOCKET, NN_SNDFD)
    }
    func getReceiveFD() throws -> Int32 {
        return try getOption(NN_SOL_SOCKET, NN_RCVFD)
    }
    func getSocketName() throws -> String {
        return try getOption(NN_SOL_SOCKET, NN_SOCKET_NAME)
    }
}


extension Socket {
    func getRequestResendInterval() throws -> Int32 {
        return try getOption(NN_REQ, NN_REQ_RESEND_IVL)
    }
    
//    func getSubscribe() throws -> Data {
//        return try getOption(NN_SUB, NN_SUB_SUBSCRIBE)
//    }
//    func getUnsubscribe() throws -> Data {
//        return try getOption(NN_SUB, NN_SUB_UNSUBSCRIBE)
//    }
//    
    func getSurveyorDeadline() throws -> Int32 {
        return try getOption(NN_SURVEYOR, NN_SURVEYOR_DEADLINE)
    }
    
    func getTcpNoDelay() throws -> Bool {
        return try getOption(NN_TCP, NN_TCP_NODELAY)
    }
    
    func getWsMsgType() throws -> Int32 {
        return try getOption(NN_WS, NN_WS_MSG_TYPE)
    }
}

