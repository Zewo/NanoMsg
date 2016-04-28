
import C7


let s1 = try Socket(type: .pub)

let address = "tcp://127.0.0.1:8084"

try s1.bind(address)
print("lol)")

let s2 = try Socket(type: .sub)



try s2.connect(address)

try s2.setSubscribe([])

for i in 0..<5 {
    let s = "asdasdasdasdasdasdasdsadsaasd\(i)"
    let d = Data(s)
    s1.send(d)

}

while true {
    let res = s2.receive()
    print(res)
//    print(res.bytes)
}


