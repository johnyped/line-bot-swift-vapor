import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { req async throws in
        try await req.view.render("index", ["title": "Hello Vapor!"])
    }

    app.get("hello") { req async -> String in
        "Hello, world!"
    }

    app.post("webhook") { req async throws -> String in
        let body = try await req.body.collect(upTo: 1024 * 1024 * 10)
        let json = try JSONSerialization.jsonObject(with: body)        
        //print header
        print("--------------------------------")
        print("header:")
        print(req.headers)
        
        print("--------------------------------")
        print("body:")
        print(body)    
        
        print("--------------------------------")
        print("json:")
        print(json)
        
        return "OK"
    }

    // try app.register(collection: TodoController())
}

/*
//webhook json body
{
  "destination": "xxxxxxxxxx",
  "events": [
    {
      "type": "message",
      "message": {
        "type": "text",
        "id": "14353798921116",
        "text": "Hello, world"
      },
      "timestamp": 1625665242211,
      "source": {
        "type": "user",
        "userId": "U80696558e1aa831..."
      },
      "replyToken": "757913772c4646b784d4b7ce46d12671",
      "mode": "active",
      "webhookEventId": "01FZ74A0TDDPYRVKNK77XKC3ZR",
      "deliveryContext": {
        "isRedelivery": false
      }
    },
    {
      "type": "follow",
      "timestamp": 1625665242214,
      "source": {
        "type": "user",
        "userId": "Ufc729a925b3abef..."
      },
      "replyToken": "bb173f4d9cf64aed9d408ab4e36339ad",
      "mode": "active",
      "webhookEventId": "01FZ74ASS536FW97EX38NKCZQK",
      "deliveryContext": {
        "isRedelivery": false
      }
    },
    {
      "type": "unfollow",
      "timestamp": 1625665242215,
      "source": {
        "type": "user",
        "userId": "Ubbd4f124aee5113..."
      },
      "mode": "active",
      "webhookEventId": "01FZ74B5Y0F4TNKA5SCAVKPEDM",
      "deliveryContext": {
        "isRedelivery": false
      }
    }
  ]
}
*/

