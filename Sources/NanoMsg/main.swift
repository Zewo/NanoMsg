
import C7


let s = try Socket(type: .pull)

let address = "tcp://127.0.0.1:8084"

try s.bind(address)
print("lol)")

let s2 = try Socket(type: .push)


try s2.connect(address)
for i in 0..<2 {
    let s = "asdasdasdasdasdasdasdsadsaasd\(i)"
    print(i)
    let d = Data(s)
    s2.send(d)

}

while true {
    let res = s.receive()
    print(res)
//    print(res.bytes)
}


