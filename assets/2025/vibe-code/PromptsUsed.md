# Prompts

These are the prompts that I'll be using.

## 01 - Initial build out

We are going to be developing a solution to parse current auctions on [Nellis Auctions](https://www.nellisauction.com/). Specifically, at first, we'll be grabbing the electronics first page data sorted by estimated retail high to low. So for this and the Houston, TX location, that would be `https://www.nellisauction.com/search?query=&Taxonomy+Level+1=Electronics&sortBy=retail_price_desc&_data`.

We are going to developing this in C# and ASP.NET Core Blazor (server side rendering) with .NET 9 and latest C# language features using both standard libraries and any common third party ones. For now, I want to keep this simple with two separate C# assemblies:

1. The core library that does the parsing, stores the serialization types, etc. I am imagining something like `public class NellisScanner(HttpClient httpClient, ILogger<NellisScanner> logger)` to define the type that will host all of the main methods. A core one should be to fetch current results for a given page as an argument. In addition, it should expose a method to query for a very specific auction at the `/p/NAME_OF_LISTING/Id`, but this may require HTML parsing. Another approach will be to deliver an `IAsyncEnumerable<>` by going after the server-sent event stream at `https://sse.nellisauction.com/live-products?productId=Id`.
2. The primary ASP.NET Core application with a Blazor interface will utilize a task runner e.g. Hangfire to scan and store the data from above every 5 minutes. For auctions closing in the 30 minutes, we'll need to check on them sooner because, when an auction is under 30 seconds of time remaining, bids will increase the time. The Blazor side of this problem will just display all of the inventory Ids, names, and show a price history.

Other details:

* We will want to run this in Docker, so create the appropriate Dockerfiles as well.
* We will be using a Docker instance of PostgreSQL. When developing this code, assume whatever username/password feels good. Let's use the latest version i.e. 17 and preferably a container that automatically upgrades when necessary.
* The username/password should be passed into the Blazor application via the `appsettings.json` via a standard methodology.
* Because we are going to be using Docker heavily, we mind as well create a `docker-compose.yml` while we are at it. Define the username/password as environment variables or as Docker secrets and the humans involved will set it up accordingly.
* We are wanting to use EF Core with PostgreSQL. Specifically, this should be code-first with migrations created.
* For now, there does not need to be a public API on the Blazor assembly. This can be SSR.

### Example return of the search route

```json
{
  "currentShoppingLocation": {
    "id": 5,
    "name": "Houston, TX",
    "locationPhoto": []
  },
  "discoverySource": "algolia_strategy_a_sort_by_retail_price_desc",
  "facets": {
    "category": {
      "Electronics": 1253
    },
    "locationName": {
      "Katy": 1253
    },
    "auctionEventName": {
      "Daily Auction - Katy - Apr 24th": 1253
    },
    "auctionEventType": {
      "Retail Returns": 1253
    },
    "starRating": {
      "5.0": 1031,
      "4.0": 151,
      "3.0": 59,
      "2.0": 11,
      "1.0": 1
    },
    "suggestedRetail": {
      "10.0": 55,
      "12.63": 33,
      "9.99": 23,
      "19.99": 20,
      "6.99": 19,
      "18.3": 17,
      "16.37": 12,
      "6.0": 12,
      "6.52": 12,
      "14.99": 11,
      "15.99": 11,
      "18.99": 11,
      "8.0": 11,
      "9.44": 11,
      "22.98": 10,
      "8.66": 10,
      "8.89": 9,
      "11.97": 8,
      "12.0": 8,
      "12.95": 8
    },
    "taxonomy1": {
      "Clothing, Shoes & Accessories": 4087,
      "Home & Household Essentials": 3488,
      "Electronics": 1253,
      "Beauty & Personal Care": 1193,
      "Automotive": 725,
      "Home Improvement": 682,
      "Pet Supplies": 449,
      "Toys & Games": 428,
      "Outdoors & Sports": 427,
      "Patio & Garden": 427,
      "Food, Supplements & Pantry": 425,
      "Furniture & Appliances": 424,
      "Baby": 375,
      "Office & School Supplies": 308,
      "Books, Music & Media": 117,
      "Bulk and Mixed Items": 72,
      "Smart Home": 10
    },
    "taxonomy2": {
      "Cell Phones, Chargers & Accessories": 485,
      "Computers, Laptops, Tablets & Accessories": 270,
      "Cameras & Photography Equipment": 117,
      "Headphones": 93,
      "TVs": 60,
      "Speakers": 44,
      "Networking & Drives": 30,
      "Wearable Technology": 24,
      "Printers & Printer Accessories": 20,
      "Monitors & Monitor Stands": 6,
      "Computer Mice & Mouse Pads": 1,
      "Keyboards": 1
    }
  },
  "filterCount": 1,
  "algolia": {
    "page": 0,
    "nbPages": 11,
    "nbHits": 1253,
    "query": "",
    "hitsPerPage": 120,
    "queryID": "69a9d02de9599832ab3ced00b4294957",
    "indexUsed": "nellisauction-prd-strategy-a_retail_price_desc"
  },
  "products": [
    {
      "id": 50239818,
      "grade": {
        "categoryType": null,
        "assemblyType": {
          "id": 2,
          "description": "No"
        },
        "missingPartsType": {
          "id": 6,
          "description": "No"
        },
        "functionalType": {
          "id": 1,
          "description": "Yes"
        },
        "conditionType": {
          "id": 5,
          "description": "New"
        },
        "damageType": {
          "id": 7,
          "description": "None"
        },
        "packageType": {
          "id": 5,
          "description": "Yes"
        },
        "rating": 5
      },
      "title": "SIOXCFZ 43 inch Rechargeable Portable Outdoor Digital Signage Displays, 4K UHD,IP55 Waterproof, Smart LCD Split Screen, Movable Kiosk, Brightness Auto-Adjustment,Android OS",
      "inventoryNumber": "1042792017",
      "photos": [
        {
          "url": "https://images-na.ssl-images-amazon.com/images/I/51ahFAXE3zL.jpg",
          "name": "https://images-na.ssl-images-amazon.com/images/I/51ahFAXE3zL.jpg",
          "fullPath": "https://images-na.ssl-images-amazon.com/images/I/51ahFAXE3zL.jpg"
        },
        {
          "url": "https://firebasestorage.googleapis.com/v0/b/nellishr-cbba0.appspot.com/o/processing-photos%2F1042792017%2FbwARHhgXZsH7NkISutIK6.jpeg?alt=media&token=4275c61a-1589-4e94-acfe-ef9f76f87379",
          "name": "bwARHhgXZsH7NkISutIK6.jpeg",
          "fullPath": "processing-photos/1042792017/bwARHhgXZsH7NkISutIK6.jpeg"
        }
      ],
      "retailPrice": 2480.67,
      "notes": "FACTORY SEAL ",
      "bidCount": 25,
      "currentPrice": 601,
      "openTime": {
        "__type": "Date",
        "value": "2025-04-25T02:01:48.208Z"
      },
      "closeTime": {
        "__type": "Date",
        "value": "2025-04-26T01:31:00.000Z"
      },
      "isClosed": false,
      "marketStatus": "open",
      "location": {
        "id": 5,
        "name": "Katy",
        "offsite": false,
        "timezone": "America/Chicago",
        "address": "3615 W Grand Pkwy N",
        "city": "Katy",
        "state": "TX",
        "zipCode": 77449
      },
      "originType": "revalidate",
      "extensionInterval": 30,
      "initialCloseTime": {
        "__type": "Date",
        "value": "2025-04-26T01:31:00.000Z"
      },
      "projectExtended": false
    },
    {
      "id": 48770191,
      "grade": {
        "categoryType": null,
        "assemblyType": {
          "id": 2,
          "description": "No"
        },
        "missingPartsType": {
          "id": 6,
          "description": "No"
        },
        "functionalType": {
          "id": 1,
          "description": "Yes"
        },
        "conditionType": {
          "id": 5,
          "description": "New"
        },
        "damageType": {
          "id": 7,
          "description": "None"
        },
        "packageType": {
          "id": 5,
          "description": "Yes"
        },
        "rating": 5
      },
      "title": "OM SYSTEM Olympus OM-1 Mark II Micro Four Thirds System Camera 20MP BSI Stacked Sensor Weather Sealed Design (US Manufacturer Warranty)",
      "inventoryNumber": "1039125608",
      "photos": [
        {
          "url": "https://images-na.ssl-images-amazon.com/images/I/81d63nSTMTL.jpg",
          "name": "https://images-na.ssl-images-amazon.com/images/I/81d63nSTMTL.jpg",
          "fullPath": "https://images-na.ssl-images-amazon.com/images/I/81d63nSTMTL.jpg"
        },
        {
          "url": "https://firebasestorage.googleapis.com/v0/b/nellishr-cbba0.appspot.com/o/processing-photos%2F1039125608%2F_1GoqSaGb0tmxqAQt2d0q.jpeg?alt=media&token=b3094c60-5e9a-4f8c-aa06-24dada3bfe48",
          "name": "_1GoqSaGb0tmxqAQt2d0q.jpeg",
          "fullPath": "processing-photos/1039125608/_1GoqSaGb0tmxqAQt2d0q.jpeg"
        },
        {
          "url": "https://firebasestorage.googleapis.com/v0/b/nellishr-cbba0.appspot.com/o/processing-photos%2F1039125608%2Fs4jcNXJcNXRvLaONIwRM8.jpeg?alt=media&token=570f4629-fdc6-48f9-979a-3ba3ac2f1200",
          "name": "s4jcNXJcNXRvLaONIwRM8.jpeg",
          "fullPath": "processing-photos/1039125608/s4jcNXJcNXRvLaONIwRM8.jpeg"
        },
        {
          "url": "https://firebasestorage.googleapis.com/v0/b/nellishr-cbba0.appspot.com/o/processing-photos%2F1039125608%2FiCXlxL19mtSKkT-M0AYi3.jpeg?alt=media&token=2f8d3ba2-b344-41f3-91cf-6f50979e58cb",
          "name": "iCXlxL19mtSKkT-M0AYi3.jpeg",
          "fullPath": "processing-photos/1039125608/iCXlxL19mtSKkT-M0AYi3.jpeg"
        },
        {
          "url": "https://firebasestorage.googleapis.com/v0/b/nellishr-cbba0.appspot.com/o/processing-photos%2F1039125608%2FFxqJ4NmPqHXRWhhM1TspD.jpeg?alt=media&token=49e32edd-b527-49cd-9206-50e7445e9716",
          "name": "FxqJ4NmPqHXRWhhM1TspD.jpeg",
          "fullPath": "processing-photos/1039125608/FxqJ4NmPqHXRWhhM1TspD.jpeg"
        }
      ],
      "retailPrice": 2122.21,
      "notes": null,
      "bidCount": 33,
      "currentPrice": 619,
      "openTime": {
        "__type": "Date",
        "value": "2025-04-25T02:01:48.208Z"
      },
      "closeTime": {
        "__type": "Date",
        "value": "2025-04-26T00:31:00.000Z"
      },
      "isClosed": false,
      "marketStatus": "open",
      "location": {
        "id": 5,
        "name": "Katy",
        "offsite": false,
        "timezone": "America/Chicago",
        "address": "3615 W Grand Pkwy N",
        "city": "Katy",
        "state": "TX",
        "zipCode": 77449
      },
      "originType": "revalidate",
      "extensionInterval": 30,
      "initialCloseTime": {
        "__type": "Date",
        "value": "2025-04-26T00:31:00.000Z"
      },
      "projectExtended": false
    },
    {
      "id": 49458194,
      "grade": {
        "categoryType": null,
        "assemblyType": {
          "id": 2,
          "description": "No"
        },
        "missingPartsType": {
          "id": 6,
          "description": "No"
        },
        "functionalType": {
          "id": 1,
          "description": "Yes"
        },
        "conditionType": {
          "id": 5,
          "description": "New"
        },
        "damageType": {
          "id": 7,
          "description": "None"
        },
        "packageType": {
          "id": 5,
          "description": "Yes"
        },
        "rating": 5
      },
      "title": "Apple 2024 MacBook Pro Laptop with M4 Pro, 12?core CPU, 16?core GPU: Built for Apple Intelligence, 14.2-inch Liquid Retina XDR Display, 24GB Unified Memory, 512GB SSD Storage; Silver",
      "inventoryNumber": "1045246973",
      "photos": [
        {
          "url": "https://images-na.ssl-images-amazon.com/images/I/613RuHJEBQL.jpg",
          "name": "https://images-na.ssl-images-amazon.com/images/I/613RuHJEBQL.jpg",
          "fullPath": "https://images-na.ssl-images-amazon.com/images/I/613RuHJEBQL.jpg"
        },
        {
          "url": "https://firebasestorage.googleapis.com/v0/b/nellishr-cbba0.appspot.com/o/processing-photos%2F1045246973%2FxiRV1PUPvqNKIMMldaOWK.jpeg?alt=media&token=5136ab9c-fc8b-401f-a695-27c84b5ef29c",
          "name": "xiRV1PUPvqNKIMMldaOWK.jpeg",
          "fullPath": "processing-photos/1045246973/xiRV1PUPvqNKIMMldaOWK.jpeg"
        },
        {
          "url": "https://firebasestorage.googleapis.com/v0/b/nellishr-cbba0.appspot.com/o/processing-photos%2F1045246973%2FvN6sFjAWmrrhCDwkfFEJt.jpeg?alt=media&token=241dfe51-ba80-4d89-bd14-ea858cf6ced7",
          "name": "vN6sFjAWmrrhCDwkfFEJt.jpeg",
          "fullPath": "processing-photos/1045246973/vN6sFjAWmrrhCDwkfFEJt.jpeg"
        },
        {
          "url": "https://firebasestorage.googleapis.com/v0/b/nellishr-cbba0.appspot.com/o/processing-photos%2F1045246973%2FHjJ-2Wst9PA36ONbIfHCb.jpeg?alt=media&token=53077ff3-1f1b-45fe-ab59-d5358f8d4200",
          "name": "HjJ-2Wst9PA36ONbIfHCb.jpeg",
          "fullPath": "processing-photos/1045246973/HjJ-2Wst9PA36ONbIfHCb.jpeg"
        }
      ],
      "retailPrice": 1999,
      "notes": "ITEM IS SEALED!",
      "bidCount": 32,
      "currentPrice": 1264,
      "openTime": {
        "__type": "Date",
        "value": "2025-04-25T02:01:48.208Z"
      },
      "closeTime": {
        "__type": "Date",
        "value": "2025-04-26T00:03:00.000Z"
      },
      "isClosed": false,
      "marketStatus": "open",
      "location": {
        "id": 5,
        "name": "Katy",
        "offsite": false,
        "timezone": "America/Chicago",
        "address": "3615 W Grand Pkwy N",
        "city": "Katy",
        "state": "TX",
        "zipCode": 77449
      },
      "originType": "revalidate",
      "extensionInterval": 30,
      "initialCloseTime": {
        "__type": "Date",
        "value": "2025-04-26T00:03:00.000Z"
      },
      "projectExtended": false
    },
    {
      "id": 49614077,
      "grade": {
        "categoryType": {
          "id": 6,
          "description": "General Merchandise"
        },
        "assemblyType": {
          "id": 2,
          "description": "No"
        },
        "missingPartsType": {
          "id": 6,
          "description": "No"
        },
        "functionalType": {
          "id": 4,
          "description": "Untested"
        },
        "conditionType": {
          "id": 6,
          "description": "Used"
        },
        "damageType": {
          "id": 7,
          "description": "None"
        },
        "packageType": {
          "id": 5,
          "description": "Yes"
        },
        "rating": 3.56
      },
      "title": "TP-Link Deco BE33000 Quad-Band WiFi 7 Mesh System (Deco BE95) for Whole Home Coverage up to 7800 Sq.Ft with AI-Driven Smart Antennas, 10G Multi-Gig Ethernet ports, Replaces Router and Extender(2-pack)",
      "inventoryNumber": "1043076943",
      "photos": [
        {
          "url": "https://images-na.ssl-images-amazon.com/images/I/31VlNXQwiWL.jpg",
          "name": "https://images-na.ssl-images-amazon.com/images/I/31VlNXQwiWL.jpg",
          "fullPath": "https://images-na.ssl-images-amazon.com/images/I/31VlNXQwiWL.jpg"
        },
        {
          "url": "https://firebasestorage.googleapis.com/v0/b/nellishr-cbba0.appspot.com/o/processing-photos%2F1043076943%2FDDIZKwNn-11XbQJW02lkm.jpeg?alt=media&token=f0ba1605-1339-48db-865d-43d534b55f81",
          "name": "DDIZKwNn-11XbQJW02lkm.jpeg",
          "fullPath": "processing-photos/1043076943/DDIZKwNn-11XbQJW02lkm.jpeg"
        },
        {
          "url": "https://firebasestorage.googleapis.com/v0/b/nellishr-cbba0.appspot.com/o/processing-photos%2F1043076943%2FMx4Tqyj3OzvrrQPO1-iSp.jpeg?alt=media&token=d853a691-a384-4f01-b32a-24ae3a6e77e1",
          "name": "Mx4Tqyj3OzvrrQPO1-iSp.jpeg",
          "fullPath": "processing-photos/1043076943/Mx4Tqyj3OzvrrQPO1-iSp.jpeg"
        },
        {
          "url": "https://firebasestorage.googleapis.com/v0/b/nellishr-cbba0.appspot.com/o/processing-photos%2F1043076943%2FeHEQ43sWW__NZtKoooOlz.jpeg?alt=media&token=92b3b765-5656-4127-b339-de8e7a03b6ab",
          "name": "eHEQ43sWW__NZtKoooOlz.jpeg",
          "fullPath": "processing-photos/1043076943/eHEQ43sWW__NZtKoooOlz.jpeg"
        },
        {
          "url": "https://firebasestorage.googleapis.com/v0/b/nellishr-cbba0.appspot.com/o/processing-photos%2F1043076943%2Fduq44A6yFTUP1EzI32t9z.jpeg?alt=media&token=4a7a968b-4ad3-44e7-be6e-11b98391bbc7",
          "name": "duq44A6yFTUP1EzI32t9z.jpeg",
          "fullPath": "processing-photos/1043076943/duq44A6yFTUP1EzI32t9z.jpeg"
        }
      ],
      "retailPrice": 875.62,
      "notes": null,
      "bidCount": 13,
      "currentPrice": 205,
      "openTime": {
        "__type": "Date",
        "value": "2025-04-25T02:01:48.208Z"
      },
      "closeTime": {
        "__type": "Date",
        "value": "2025-04-26T00:43:00.000Z"
      },
      "isClosed": false,
      "marketStatus": "open",
      "location": {
        "id": 5,
        "name": "Katy",
        "offsite": false,
        "timezone": "America/Chicago",
        "address": "3615 W Grand Pkwy N",
        "city": "Katy",
        "state": "TX",
        "zipCode": 77449
      },
      "originType": "revalidate",
      "extensionInterval": 30,
      "initialCloseTime": {
        "__type": "Date",
        "value": "2025-04-26T00:43:00.000Z"
      },
      "projectExtended": false
    }
  ],
  "trendingProducts": [],
  "searchResultsCount": 1253,
  "selectedFilters": [
    "Taxonomy%20Level%201:Electronics"
  ],
  "autocompleteFilters": {
    "filters": "\"Shopping Location\":\"Houston, TX\" AND \"Market Status\":\"open\" AND \"Sensitive\":0",
    "facetFilters": [
      [
        "Taxonomy Level 1:Electronics"
      ]
    ],
    "numericFilters": [
      "Time Remaining \u003E= 1745601486"
    ],
    "filterCount": 1
  }
}
```

### Example Single Product

```json
{
  "id": 50239818,
  "grade": {
    "categoryType": null,
    "assemblyType": {
      "id": 2,
      "description": "No"
    },
    "missingPartsType": {
      "id": 6,
      "description": "No"
    },
    "functionalType": {
      "id": 1,
      "description": "Yes"
    },
    "conditionType": {
      "id": 5,
      "description": "New"
    },
    "damageType": {
      "id": 7,
      "description": "None"
    },
    "packageType": {
      "id": 5,
      "description": "Yes"
    },
    "rating": 5
  },
  "title": "SIOXCFZ 43 inch Rechargeable Portable Outdoor Digital Signage Displays, 4K UHD,IP55 Waterproof, Smart LCD Split Screen, Movable Kiosk, Brightness Auto-Adjustment,Android OS",
  "inventoryNumber": "1042792017",
  "photos": [
    {
      "url": "https://images-na.ssl-images-amazon.com/images/I/51ahFAXE3zL.jpg",
      "name": "https://images-na.ssl-images-amazon.com/images/I/51ahFAXE3zL.jpg",
      "fullPath": "https://images-na.ssl-images-amazon.com/images/I/51ahFAXE3zL.jpg"
    },
    {
      "url": "https://firebasestorage.googleapis.com/v0/b/nellishr-cbba0.appspot.com/o/processing-photos%2F1042792017%2FbwARHhgXZsH7NkISutIK6.jpeg?alt=media&token=4275c61a-1589-4e94-acfe-ef9f76f87379",
      "name": "bwARHhgXZsH7NkISutIK6.jpeg",
      "fullPath": "processing-photos/1042792017/bwARHhgXZsH7NkISutIK6.jpeg"
    }
  ],
  "retailPrice": 2480.67,
  "notes": "FACTORY SEAL ",
  "bidCount": 25,
  "currentPrice": 601,
  "openTime": {
    "__type": "Date",
    "value": "2025-04-25T02:01:48.208Z"
  },
  "closeTime": {
    "__type": "Date",
    "value": "2025-04-26T01:31:00.000Z"
  },
  "isClosed": false,
  "marketStatus": "open",
  "location": {
    "id": 5,
    "name": "Katy",
    "offsite": false,
    "timezone": "America/Chicago",
    "address": "3615 W Grand Pkwy N",
    "city": "Katy",
    "state": "TX",
    "zipCode": 77449
  },
  "originType": "revalidate",
  "extensionInterval": 30,
  "initialCloseTime": {
    "__type": "Date",
    "value": "2025-04-26T01:31:00.000Z"
  },
  "projectExtended": false
}
```

### Example return of the server-sent event stream

```text
id:control-1745601903658
event:message
retry:100
data:connected 042e6717-7590-4e33-b4e9-f62c3822c6a5,0xc00261cc40-0xc00261ccb0

id:control-1745601904659
event:message
retry:100
data:ping

id:control-1745601905658
event:message
retry:100
data:ping
```

### Result/Observations

I copied the entire above minus the root header and pasted it in. I sent the command with codebase included as part of the context.

#### About the Process

1. GitHub Copilot in Agent mode did indeed run lots of local commands against `dotnet` to create projects.
2. It did run troubleshooting when it ran into issues. For example, at first, I had not yet installed the .NET 9 SDK on the machine which means the VS Code environment variables hadn't been updated to be able to use `dotnet` successfully. However, instead of just bailing, it decided to check if PowerShell was working by having it do a test output first I suppose to ensure that PowerShell wasn't missing and could better instruct the user if the SDK was needed. I just stopped it there and restarted the chat after refreshing the environment variables in the PowerShell session.
3. It can take quite a few minutes to "cook" as one may say.
4. One thing I thought was somewhat impressive was it encountered an issue deploying the Blazor template with server side rendering. It seems that the template options may have changed from 8 to 9. Now, to me, I would just go to google with the error, but it actually chose to get the help for the template using `dotnet new blazor --help` to determine what the new parameters are. Effectively, it tried `--server` but then needed to use `--int Server` instead.  
5. It did successfully get the `dotnet ef` tool by asking to global install it.
6. To actually get the migration created, it did in fact need to build the solution which meant fixing issues. Again, watching the process, it was pretty fascinating how the tooling in VS Code even shows you what is happening.
7. I did have to enable the VS Code option `chat.tools.autoApprove` from [here](https://github.com/microsoft/vscode/issues/243357) to quiet it down some. I totally see why the standard/default should be false, but for me, this should be no big deal at first.

#### About the Code

1. I liked the Dockerfile for copying explicitly the csproj files first to restore. This is a well-known optimization, but it's tedious to implement at times especially with changing internal references. However, it's not using the [chisled images](https://devblogs.microsoft.com/dotnet/announcing-dotnet-chiseled-containers/). Perhaps this is understood while you're still doing things, but it's not.
2. Didn't use the primary constructor when it could. Stylistic decision only.
3. Left the `Class1.cs` that were created with the template. Just funny.
4. Really bizarre mixed use of `[JsonPropertyName]`. Like, no rhyme or reason.
5. Tried to use `/_data` when I prescribed using it as a query parameter i.e. `?_data` or `&_data`.
6. Did not imagine what the type of data that could be returned in `MonitorProductUpdatesAsync` with the event stream. We didn't get an observation off, but it focused too much within itself.
7. I thought this was a subtle but totally weird thing. For the event stream found at `MonitorProductUpdatesAsync`, it knows the example did not demonstrate any JSON characteristics hence the `Substring` use, but then down below, it just deserializes it blankly. Maybe it imagined the data would be JSON during that instead, but to me, having APIs that change convention based on what type of data and thus requires extra parsing just feels bad.
8. I really liked the use `JsonConverter<DateTimeOffset>`. Not sure it was totally necessary.

Something I now realize is that I did not fully explain that an auction can run on the same item multiple times and that I don't want to see the progression of the auction - only the closing price. I also want to test the core API checkers, but I am not a fane of mocking for external integration as the problems it can inform you of are fairly small.

## 02 - Fixes Needed

Alright, so we created the core and web applications. There are some fixes we are going to focus on.

First, I'd like to fix a preconception of the first attempt. Instead of tracking price as it changes, I only want to keep track of the final price that we capture. The `Id` of the auction allows you to query for the details found at, for example, `https://www.nellisauction.com/p/Product-Name-With-Dashes/$id`. For example, that yields something like:

```html
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charSet="utf-8"/>
        <meta name="viewport" content="width=device-width,initial-scale=1"/>
        <title>Speediance Gym Monster 2 Smart Home Gym, Upgraded AI-Powered Home Workout Machine, Multi-Functional Smith Machine, Full Body Strength Training Fitness Equipment, All-in-One Workout Station for sale | Katy, TX | Nellis Auction</title>
        <meta name="description" content="Sold for $503 | Retail: $4200 | Speediance Gym Monster 2 Smart Home Gym, Upgraded AI-Powered Home Workout Machine, Multi-Functional Smith Machine, Full Body Strength Training Fitness Equipment, All-in-One Workout Station | Houston, TX"/>
        <meta name="title" content="Speediance Gym Monster 2 Smart Home Gym, Upgraded AI-Powered Home Workout Machine, Multi-Functional Smith Machine, Full Body Strength Training Fitness Equipment, All-in-One Workout Station for sale | Katy, TX | Nellis Auction"/>
        <meta name="viewport" content="width=device-width,initial-scale=1"/>
        <meta property="og:type" content="website"/>
        <meta property="og:url" content="https://www.nellisauction.com/p/Speediance-Gym-Monster-2-Smart-Home-Gym-Upgraded-AI-Powered-Home/50504133"/>
        <meta property="og:title" content="Speediance Gym Monster 2 Smart Home Gym, Upgraded AI-Powered Home Workout Machine, Multi-Functional Smith Machine, Full Body Strength Training Fitness Equipment, All-in-One Workout Station"/>
        <meta property="og:image" content="https://images-na.ssl-images-amazon.com/images/I/61s+dEzQFTL.jpg"/>
        <meta property="og:image:alt" content="first image of Speediance Gym Monster 2 Smart Home Gym, Upgraded AI-Powered Home Workout Machine, Multi-Functional Smith Machine, Full Body Strength Training Fitness Equipment, All-in-One Workout Station"/>
        <meta property="og:site_name" content="Nellis Auction"/>
        <meta name="twitter:card" content="summary_large_image"/>
        <meta name="twitter:domain" content="www.nellisauction.com"/>
        <meta name="description" content="Auction Ends: Mon Apr 28, 8:26PM CDT"/>
        <meta name="twitter:label1" content="Current Bid Price"/>
        <meta name="twitter:data1" content="$503"/>
        <meta name="twitter:label2" content="Retail Price"/>
        <meta name="twitter:data2" content="$4200"/>
        <link rel="icon" type="image/x-icon" href="/favicon.ico"/>
        <link rel="apple-touch-icon" sizes="180x180" href="/apple-touch-icon.png"/>
        <link rel="manifest" href="/site.webmanifest"/>
        <link rel="preconnect" href="https://fonts.googleapis.com"/>
        <link rel="preconnect" href="https://fonts.gstatic.com"/>
        <link rel="preconnect" href="https://googletagmanager.com"/>
        <link rel="preconnect" href="https://briskeagle.io"/>
        <link rel="preconnect" href="https://ssl.kaptcha.com"/>
        <link rel="preconnect" href="https://static.zdassets.com/"/>
        <link rel="prefetch" href="/assets/fonts/open-sans-v34-latin-300.woff2"/>
        <link rel="prefetch" href="/assets/fonts/open-sans-v34-latin-400.woff2"/>
        <link rel="prefetch" href="/assets/fonts/open-sans-v34-latin-600.woff2"/>
        <link rel="prefetch" href="/assets/fonts/open-sans-v34-latin-700.woff2"/>
        <link rel="stylesheet" href="/build/_assets/fonts-HRT7CMH7.css"/>
        <link rel="stylesheet" href="/build/_assets/tailwind-FJTGRVCA.css"/>
        <link rel="stylesheet" href="/build/_assets/main-P2IC2455.css"/>
        <script>
            window.ENV = {
                "APP_PUBLIC_ALGOLIA_API_KEY": "d22f83c614aa8eda28fa9eadda0d07b9",
                "APP_PUBLIC_ALGOLIA_ID": "GL1QVP8R29",
                "APP_PUBLIC_ALGOLIA_INDEX": "nellisauction-prd",
                "APP_PUBLIC_ALGOLIA_QUERY_SUGGESTIONS_DEFAULT_INDEX": "nellisauction-prd_query_suggestions_default",
                "APP_PUBLIC_AUTO_PILOT_CLIENT_TOKEN": "eefdd74773a54cc1b43e558b34d33fe8f0c0c8555a25484aa42e180d26af0ca4",
                "APP_PUBLIC_BUYER_FRONTEND_URL": "https://www.nellisauction.com",
                "APP_PUBLIC_FACEBOOK_PIXEL_ID": "",
                "APP_PUBLIC_GOOGLE_ANALYTICS_APP_ID": "UA-39323446-2",
                "APP_PUBLIC_GOOGLE_API_KEY": "AIzaSyB61qnxZvOGUcvmZNNDIyEh-DcwgN5W930",
                "APP_PUBLIC_GOOGLE_MAPS_API_KEY": "AIzaSyB61qnxZvOGUcvmZNNDIyEh-DcwgN5W930",
                "APP_PUBLIC_GOOGLE_SITE_VERIFICATION": "QsidqRM-HnmZMhcfra_uJBglmmZ0O-wpLJ87z2OfiBY",
                "APP_PUBLIC_GOOGLE_TAG_MANAGER_ID": "GTM-WB9L6N3",
                "APP_PUBLIC_KLAVIYO_PUBLIC_API_KEY": "UDQmHy",
                "APP_PUBLIC_KOUNT_COLLECTOR_HOSTNAME": "ssl.kaptcha.com",
                "APP_PUBLIC_KOUNT_MERCHANT_ID": "100066",
                "APP_PUBLIC_NELLIS_API_URL": "https://cargo.prd.nellis.run/api",
                "APP_PUBLIC_SENTRY_DSN": "https://b61eb32f6d314323a9758b0f9c2dc18f@o103832.ingest.sentry.io/5837505",
                "APP_PUBLIC_SSE_URL": "https://sse.nellisauction.com",
                "APP_PUBLIC_HEAP_APP_ID": "",
                "APP_PUBLIC_SENTRY_ENVIRONMENT": "",
                "APP_PUBLIC_BUILD_INFO": "{\"GIT_COMMIT_REF\":\"prd\",\"GIT_COMMIT_SHA\":\"dc7ce6e939bc25ad4cef6aef7c73738ba07692b7\",\"GIT_COMMIT_TIMESTAMP\":\"2025-04-09T20:00:49Z\",\"GIT_TAG\":\"release/v2025.1.3\",\"VERSION\":\"v2025.1.3\"}",
                "APP_PUBLIC_DOMAIN": ""
            };
            window.dataLayer = window.dataLayer || [];
        </script>
    </head>
    <body class="kaxsdc" data-event="load">
        <noscript>
            <iframe title="google-tag-manager" src="https://www.googletagmanager.com/ns.html?id=GTM-WB9L6N3" height="0" width="0" style="display:none;visibility:hidden"></iframe>
        </noscript>
        <div class="flex flex-col min-h-[100vh] relative">
            <header data-ax="site-header" class="z-[100] bg-white shadow-header sticky top-0">
                <div class="relative md:h-[4.813rem] h-[6.8125rem]">
                    <div class="flex md:hidden flex-col justify-center p-3 h-full">
                        <div class="flex items-center justify-between">
                            <a aria-label="Go to home page" data-ax="logo" class="focus:outline-secondary" data-discover="true" href="/">
                                <img class="h-8 md:h-14 min-w-[6.75rem] md:min-w-48" src="/assets/svg/NALogo.svg" alt="Nellis Auction Logo"/>
                            </a>
                            <div class="relative flex items-center lg:hidden gap-x-5 justify-end">
                                <button aria-label="Toggle menu" class="w-full lg:hidden" type="button" data-ax="mobile-hamburger-menu">
                                    <div class="relative flex items-center justify-center">
                                        <svg xmlns="http://www.w3.org/2000/svg" width="28" height="28" class="fill-gray-900" viewBox="0 0 448 512">
                                            <path d="M0 88C0 74.7 10.7 64 24 64H424c13.3 0 24 10.7 24 24s-10.7 24-24 24H24C10.7 112 0 101.3 0 88zM0 248c0-13.3 10.7-24 24-24H424c13.3 0 24 10.7 24 24s-10.7 24-24 24H24c-13.3 0-24-10.7-24-24zM448 408c0 13.3-10.7 24-24 24H24c-13.3 0-24-10.7-24-24s10.7-24 24-24H424c13.3 0 24 10.7 24 24z"></path>
                                        </svg>
                                    </div>
                                </button>
                            </div>
                            <div class="hidden lg:flex justify-center items-center gap-x-9 xl:gap-x-[70px]">
                                <div class="hidden lg:flex">
                                    <label aria-label="location selector" id="location-selector" class="group relative w-full cursor-pointer bg-white focus:outline-secondary" tabindex="0">
                                        <input aria-labelledby="location-selector" type="checkbox" class="hidden"/>
                                        <div class="flex flex-col text-left items-center">
                                            <div class="flex py-2 px-4 rounded-3xl group-has-[:checked]:bg-burgundy-50">
                                                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 384 512" class="fill-burgundy-900 hidden group-has-[:checked]:block" width="22" height="22">
                                                    <path d="M215.7 499.2C267 435 384 279.4 384 192C384 86 298 0 192 0S0 86 0 192c0 87.4 117 243 168.3 307.2c12.3 15.3 35.1 15.3 47.4 0zM192 128a64 64 0 1 1 0 128 64 64 0 1 1 0-128z"></path>
                                                </svg>
                                                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 384 512" class="flex fill-gray-900 group-has-[:checked]:hidden" width="22" height="22">
                                                    <path d="M352 192c0-88.4-71.6-160-160-160S32 103.6 32 192c0 15.6 5.4 37 16.6 63.4c10.9 25.9 26.2 54 43.6 82.1c34.1 55.3 74.4 108.2 99.9 140c25.4-31.8 65.8-84.7 99.9-140c17.3-28.1 32.7-56.3 43.6-82.1C346.6 229 352 207.6 352 192zm32 0c0 87.4-117 243-168.3 307.2c-12.3 15.3-35.1 15.3-47.4 0C117 435 0 279.4 0 192C0 86 86 0 192 0S384 86 384 192zm-240 0a48 48 0 1 0 96 0 48 48 0 1 0 -96 0zm48 80a80 80 0 1 1 0-160 80 80 0 1 1 0 160z"></path>
                                                </svg>
                                                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 320 512" width="22" height="22" class="fill-sincity-red-600">
                                                    <path d="M137.4 374.6c12.5 12.5 32.8 12.5 45.3 0l128-128c9.2-9.2 11.9-22.9 6.9-34.9s-16.6-19.8-29.6-19.8L32 192c-12.9 0-24.6 7.8-29.6 19.8s-2.2 25.7 6.9 34.9l128 128z"></path>
                                                </svg>
                                            </div>
                                            <p class="text-gray-900 whitespace-nowrap text-body-md">Houston, TX</p>
                                        </div>
                                        <form method="post" action="/change-shopping-location" class="absolute min-w-[200px] p-4 hidden group-has-[:checked]:flex flex-col shadow-md bg-white z-[60] text-center rounded-xl overflow-hidden top-16 -left-12 -right-12 mt-1 gap-2 text-left" data-ax="select-shopping-location-form" data-discover="true">
                                            <button type="submit" value="1" name="shoppingLocationId" class="px-4 h-9 w-full rounded-[6.25rem] text-left whitespace-nowrap focus:outline-secondary text-gray-700">Las Vegas, NV</button>
                                            <button type="submit" value="2" name="shoppingLocationId" class="px-4 h-9 w-full rounded-[6.25rem] text-left whitespace-nowrap focus:outline-secondary text-gray-700">Phoenix, AZ</button>
                                            <button type="submit" value="5" name="shoppingLocationId" class="px-4 h-9 w-full rounded-[6.25rem] text-left whitespace-nowrap focus:outline-secondary bg-burgundy-100 text-burgundy-900">Houston, TX</button>
                                            <button type="submit" value="6" name="shoppingLocationId" class="px-4 h-9 w-full rounded-[6.25rem] text-left whitespace-nowrap focus:outline-secondary text-gray-700">Philadelphia, PA</button>
                                            <button type="submit" value="7" name="shoppingLocationId" class="px-4 h-9 w-full rounded-[6.25rem] text-left whitespace-nowrap focus:outline-secondary text-gray-700">Denver, CO</button>
                                            <button type="submit" value="8" name="shoppingLocationId" class="px-4 h-9 w-full rounded-[6.25rem] text-left whitespace-nowrap focus:outline-secondary text-gray-700">Dallas, TX</button>
                                            <input aria-label="Redirect" readonly="" name="referrer" hidden="" value="/p/Speediance-Gym-Monster-2-Smart-Home-Gym-Upgraded-AI-Powered-Home/50504133"/>
                                        </form>
                                    </label>
                                </div>
                                <a class="relative block w-fit text-body-lg font-semibold rounded-[3px] py-2 px-4 border border-solid border-secondary
    hover:bg-[#B424180a]
    focus:bg-[#B424180a] focus:outline focus:outline-1 focus:outline-secondary-light
    disabled:border-gray-400 disabled:text-gray-700 dark:disabled:text-gray-400 whitespace-nowrap uppercase" data-ax="log-in-sign-up-button" data-discover="true" href="/login">
                                    <span class="flex items-center justify-center opacity-100 text-secondary dark:text-white">Log In / Sign Up</span>
                                </a>
                            </div>
                        </div>
                        <div class="mt-1.5">
                            <form method="post" action="/search" id="non-autocomplete-search-box" data-ax="header-search-form" class="flex-1" data-discover="true">
                                <div class="flex rounded-2xl outline-1 outline outline-burgundy-900 has-[input:placeholder-shown]:outline-[transparent]">
                                    <div class="has-[input:placeholder-shown]:pl-5 w-full flex flex-row-reverse rounded-l-2xl bg-neutral-100">
                                        <input aria-label="Search items" class="peer pr-2 w-full outline-none text-body-lg text-gray-900 placeholder:text-gray-700 stroke-burgundy-900 bg-neutral-100" type="search" name="query" placeholder="Explore all items..." autoComplete="off" value=""/>
                                        <button aria-label="Clear input" type="button" class="p-2 peer-placeholder-shown:hidden flex items-center justify-center" disabled="">
                                            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 384 512" width="24" height="24" class="fill-gray-900">
                                                <path d="M342.6 150.6c12.5-12.5 12.5-32.8 0-45.3s-32.8-12.5-45.3 0L192 210.7 86.6 105.4c-12.5-12.5-32.8-12.5-45.3 0s-12.5 32.8 0 45.3L146.7 256 41.4 361.4c-12.5 12.5-12.5 32.8 0 45.3s32.8 12.5 45.3 0L192 301.3 297.4 406.6c12.5 12.5 32.8 12.5 45.3 0s12.5-32.8 0-45.3L237.3 256 342.6 150.6z"></path>
                                            </svg>
                                        </button>
                                    </div>
                                    <button class="w-fit text-body-lg font-semibold rounded-[3px] py-2 px-4 bg-gradient-to-r from-primary to-[#93291E]
    hover:from-sincity-red-800 hover:to-[#7D0000]
    focus:to-[#7D0000] focus:outline focus:outline-[3px] focus:outline-[#F397A2]
    disabled:from-gray-900 disabled:to-neutral-600 md:py-3 px-6 h-full min-w-[7.375rem] rounded-l-none rounded-r-2xl" type="submit" name="_action" data-ax="explore-button" value="catalog-search">
                                        <div class="relative flex items-center justify-center">
                                            <span class="flex items-center justify-center gap-1 text-white opacity-100">EXPLORE</span>
                                        </div>
                                    </button>
                                </div>
                            </form>
                        </div>
                    </div>
                    <nav class="mx-auto max-w-screen-3xl hidden md:flex items-center gap-x-[30px] lg:gap-x-9 xl:gap-x-[70px] py-2 px-5 3xl:px-2 wide:px-0">
                        <a aria-label="Go to home page" data-ax="logo" class="focus:outline-secondary" data-discover="true" href="/">
                            <img class="h-8 md:h-14 min-w-[6.75rem] md:min-w-48" src="/assets/svg/NALogo.svg" alt="Nellis Auction Logo"/>
                        </a>
                        <form method="post" action="/search" id="non-autocomplete-search-box" data-ax="header-search-form" class="flex-1" data-discover="true">
                            <div class="flex rounded-2xl outline-1 outline outline-burgundy-900 has-[input:placeholder-shown]:outline-[transparent]">
                                <div class="has-[input:placeholder-shown]:pl-5 w-full flex flex-row-reverse rounded-l-2xl bg-neutral-100">
                                    <input aria-label="Search items" class="peer pr-2 w-full outline-none text-body-lg text-gray-900 placeholder:text-gray-700 stroke-burgundy-900 bg-neutral-100" type="search" name="query" placeholder="Explore all items..." autoComplete="off" value=""/>
                                    <button aria-label="Clear input" type="button" class="p-2 peer-placeholder-shown:hidden flex items-center justify-center" disabled="">
                                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 384 512" width="24" height="24" class="fill-gray-900">
                                            <path d="M342.6 150.6c12.5-12.5 12.5-32.8 0-45.3s-32.8-12.5-45.3 0L192 210.7 86.6 105.4c-12.5-12.5-32.8-12.5-45.3 0s-12.5 32.8 0 45.3L146.7 256 41.4 361.4c-12.5 12.5-12.5 32.8 0 45.3s32.8 12.5 45.3 0L192 301.3 297.4 406.6c12.5 12.5 32.8 12.5 45.3 0s12.5-32.8 0-45.3L237.3 256 342.6 150.6z"></path>
                                        </svg>
                                    </button>
                                </div>
                                <button class="w-fit text-body-lg font-semibold rounded-[3px] py-2 px-4 bg-gradient-to-r from-primary to-[#93291E]
    hover:from-sincity-red-800 hover:to-[#7D0000]
    focus:to-[#7D0000] focus:outline focus:outline-[3px] focus:outline-[#F397A2]
    disabled:from-gray-900 disabled:to-neutral-600 md:py-3 px-6 h-full min-w-[7.375rem] rounded-l-none rounded-r-2xl" type="submit" name="_action" data-ax="explore-button" value="catalog-search">
                                    <div class="relative flex items-center justify-center">
                                        <span class="flex items-center justify-center gap-1 text-white opacity-100">EXPLORE</span>
                                    </div>
                                </button>
                            </div>
                        </form>
                        <div class="relative flex items-center lg:hidden gap-x-5 justify-end">
                            <button aria-label="Toggle menu" class="w-full lg:hidden" type="button" data-ax="mobile-hamburger-menu">
                                <div class="relative flex items-center justify-center">
                                    <svg xmlns="http://www.w3.org/2000/svg" width="28" height="28" class="fill-gray-900" viewBox="0 0 448 512">
                                        <path d="M0 88C0 74.7 10.7 64 24 64H424c13.3 0 24 10.7 24 24s-10.7 24-24 24H24C10.7 112 0 101.3 0 88zM0 248c0-13.3 10.7-24 24-24H424c13.3 0 24 10.7 24 24s-10.7 24-24 24H24c-13.3 0-24-10.7-24-24zM448 408c0 13.3-10.7 24-24 24H24c-13.3 0-24-10.7-24-24s10.7-24 24-24H424c13.3 0 24 10.7 24 24z"></path>
                                    </svg>
                                </div>
                            </button>
                        </div>
                        <div class="hidden lg:flex justify-center items-center gap-x-9 xl:gap-x-[70px]">
                            <div class="hidden lg:flex">
                                <label aria-label="location selector" id="location-selector" class="group relative w-full cursor-pointer bg-white focus:outline-secondary" tabindex="0">
                                    <input aria-labelledby="location-selector" type="checkbox" class="hidden"/>
                                    <div class="flex flex-col text-left items-center">
                                        <div class="flex py-2 px-4 rounded-3xl group-has-[:checked]:bg-burgundy-50">
                                            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 384 512" class="fill-burgundy-900 hidden group-has-[:checked]:block" width="22" height="22">
                                                <path d="M215.7 499.2C267 435 384 279.4 384 192C384 86 298 0 192 0S0 86 0 192c0 87.4 117 243 168.3 307.2c12.3 15.3 35.1 15.3 47.4 0zM192 128a64 64 0 1 1 0 128 64 64 0 1 1 0-128z"></path>
                                            </svg>
                                            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 384 512" class="flex fill-gray-900 group-has-[:checked]:hidden" width="22" height="22">
                                                <path d="M352 192c0-88.4-71.6-160-160-160S32 103.6 32 192c0 15.6 5.4 37 16.6 63.4c10.9 25.9 26.2 54 43.6 82.1c34.1 55.3 74.4 108.2 99.9 140c25.4-31.8 65.8-84.7 99.9-140c17.3-28.1 32.7-56.3 43.6-82.1C346.6 229 352 207.6 352 192zm32 0c0 87.4-117 243-168.3 307.2c-12.3 15.3-35.1 15.3-47.4 0C117 435 0 279.4 0 192C0 86 86 0 192 0S384 86 384 192zm-240 0a48 48 0 1 0 96 0 48 48 0 1 0 -96 0zm48 80a80 80 0 1 1 0-160 80 80 0 1 1 0 160z"></path>
                                            </svg>
                                            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 320 512" width="22" height="22" class="fill-sincity-red-600">
                                                <path d="M137.4 374.6c12.5 12.5 32.8 12.5 45.3 0l128-128c9.2-9.2 11.9-22.9 6.9-34.9s-16.6-19.8-29.6-19.8L32 192c-12.9 0-24.6 7.8-29.6 19.8s-2.2 25.7 6.9 34.9l128 128z"></path>
                                            </svg>
                                        </div>
                                        <p class="text-gray-900 whitespace-nowrap text-body-md">Houston, TX</p>
                                    </div>
                                    <form method="post" action="/change-shopping-location" class="absolute min-w-[200px] p-4 hidden group-has-[:checked]:flex flex-col shadow-md bg-white z-[60] text-center rounded-xl overflow-hidden top-16 -left-12 -right-12 mt-1 gap-2 text-left" data-ax="select-shopping-location-form" data-discover="true">
                                        <button type="submit" value="1" name="shoppingLocationId" class="px-4 h-9 w-full rounded-[6.25rem] text-left whitespace-nowrap focus:outline-secondary text-gray-700">Las Vegas, NV</button>
                                        <button type="submit" value="2" name="shoppingLocationId" class="px-4 h-9 w-full rounded-[6.25rem] text-left whitespace-nowrap focus:outline-secondary text-gray-700">Phoenix, AZ</button>
                                        <button type="submit" value="5" name="shoppingLocationId" class="px-4 h-9 w-full rounded-[6.25rem] text-left whitespace-nowrap focus:outline-secondary bg-burgundy-100 text-burgundy-900">Houston, TX</button>
                                        <button type="submit" value="6" name="shoppingLocationId" class="px-4 h-9 w-full rounded-[6.25rem] text-left whitespace-nowrap focus:outline-secondary text-gray-700">Philadelphia, PA</button>
                                        <button type="submit" value="7" name="shoppingLocationId" class="px-4 h-9 w-full rounded-[6.25rem] text-left whitespace-nowrap focus:outline-secondary text-gray-700">Denver, CO</button>
                                        <button type="submit" value="8" name="shoppingLocationId" class="px-4 h-9 w-full rounded-[6.25rem] text-left whitespace-nowrap focus:outline-secondary text-gray-700">Dallas, TX</button>
                                        <input aria-label="Redirect" readonly="" name="referrer" hidden="" value="/p/Speediance-Gym-Monster-2-Smart-Home-Gym-Upgraded-AI-Powered-Home/50504133"/>
                                    </form>
                                </label>
                            </div>
                            <a class="relative block w-fit text-body-lg font-semibold rounded-[3px] py-2 px-4 border border-solid border-secondary
    hover:bg-[#B424180a]
    focus:bg-[#B424180a] focus:outline focus:outline-1 focus:outline-secondary-light
    disabled:border-gray-400 disabled:text-gray-700 dark:disabled:text-gray-400 whitespace-nowrap uppercase" data-ax="log-in-sign-up-button" data-discover="true" href="/login">
                                <span class="flex items-center justify-center opacity-100 text-secondary dark:text-white">Log In / Sign Up</span>
                            </a>
                        </div>
                    </nav>
                </div>
                <div class="bottom-0 left-0 right-0 h-[3px] opacity-0 z-[1000] transition-opacity duration-500 ease-in-out">
                    <div class="relative h-full w-full bg-transition-background z-[1001] overflow-hidden"></div>
                </div>
            </header>
            <main class="flex-auto relative">
                <div data-ax="product-page-container" class="bg-white md:bg-neutral-100">
                    <div class="sticky z-50 top-28 md:top-20 bg-neutral-200">
                        <div class="py-2.5 my-0 mx-auto flex justify-between max-w-screen-3xl px-5 3xl:px-2 wide:px-0">
                            <div class="flex gap-5 items-center overflow-hidden">
                                <a class="rounded-[0.625rem] bg-white px-2 py-1.5 text-burgundy-800 whitespace-nowrap focus-within:outline-secondary" data-discover="true" href="/search">Explore Products</a>
                                <h6 class="text-left hidden sm:block overflow-hidden overflow-ellipsis whitespace-nowrap">Speediance Gym Monster 2 Smart Home Gym, Upgraded AI-Powered Home Workout Machine, Multi-Functional Smith Machine, Full Body Strength Training Fitness Equipment, All-in-One Workout Station</h6>
                            </div>
                            <div class="flex gap-5 ml-5">
                                <div class="p-0 relative">
                                    <button class="h-9 min-w-[2.25rem] px-2 flex items-center justify-center rounded-[0.625rem] bg-white focus-within:outline-secondary" aria-disabled="false" data-ax="product-page-share-button">
                                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 448 512" class="fill-neutral-800" width="16" height="16">
                                            <path d="M352 224c53 0 96-43 96-96s-43-96-96-96-96 43-96 96c0 4 .2 8 .7 11.9l-94.1 47C145.4 170.2 121.9 160 96 160c-53 0-96 43-96 96s43 96 96 96c25.9 0 49.4-10.2 66.6-26.9l94.1 47c-.5 3.9-.7 7.8-.7 11.9 0 53 43 96 96 96s96-43 96-96-43-96-96-96c-25.9 0-49.4 10.2-66.6 26.9l-94.1-47c.5-3.9.7-7.8.7-11.9s-.2-8-.7-11.9l94.1-47c17.2 16.7 40.7 26.9 66.6 26.9z"></path>
                                        </svg>
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="sticky flex items-center xl:hidden gap-x-4 w-full bg-white z-50 px-4 pt-2 border-b-2 border-b-neutral-300 mb-2 top-[10.5rem] md:top-[8.5rem]">
                        <a class="capitalize text-neutral-600 pb-2 -mb-0.5 border-b-2 !font-normal whitespace-nowrap focus-visible:outline-secondary hover:text-neutral-900 border-transparent md:hidden" aria-label="Jump to photos section" data-discover="true" href="/p/Speediance-Gym-Monster-2-Smart-Home-Gym-Upgraded-AI-Powered-Home/50504133#photos">Photos</a>
                        <a class="capitalize text-neutral-600 pb-2 -mb-0.5 border-b-2 !font-normal whitespace-nowrap focus-visible:outline-secondary hover:text-neutral-900 border-transparent flex gap-x-1 items-center" aria-label="Jump to bidding section" data-discover="true" href="/p/Speediance-Gym-Monster-2-Smart-Home-Gym-Upgraded-AI-Powered-Home/50504133#bid-section">
                            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512" width="16" height="16">
                                <path d="M315.3 4.7c6.2 6.2 6.2 16.4 0 22.6L302.6 40 472 209.4l12.7-12.7c6.2-6.2 16.4-6.2 22.6 0s6.2 16.4 0 22.6l-24 24-96 96-24 24c-6.2 6.2-16.4 6.2-22.6 0s-6.2-16.4 0-22.6L353.4 328 184 158.6l-12.7 12.7c-6.2 6.2-16.4 6.2-22.6 0s-6.2-16.4 0-22.6l24-24 96-96 24-24c6.2-6.2 16.4-6.2 22.6 0zM206.6 136L376 305.4 449.4 232 280 62.6 206.6 136zM144 320L32 432l48 48L192 368l-48-48zm-22.6-22.6c12.5-12.5 32.8-12.5 45.3 0l12.7 12.7 49.8-49.8 22.6 22.6-49.8 49.8 12.7 12.7c12.5 12.5 12.5 32.8 0 45.3l-112 112c-12.5 12.5-32.8 12.5-45.3 0l-48-48c-12.5-12.5-12.5-32.8 0-45.3l112-112z"></path>
                            </svg>
                            <p>bid</p>
                        </a>
                        <a class="capitalize text-neutral-600 pb-2 -mb-0.5 border-b-2 !font-normal whitespace-nowrap focus-visible:outline-secondary hover:text-neutral-900 border-transparent" aria-label="Jump to details section" data-discover="true" href="/p/Speediance-Gym-Monster-2-Smart-Home-Gym-Upgraded-AI-Powered-Home/50504133#item-details">Details</a>
                        <a class="capitalize text-neutral-600 pb-2 -mb-0.5 border-b-2 !font-normal whitespace-nowrap focus-visible:outline-secondary hover:text-neutral-900 border-transparent" aria-label="Jump to bid history section" data-discover="true" href="/p/Speediance-Gym-Monster-2-Smart-Home-Gym-Upgraded-AI-Powered-Home/50504133#bid-history">Bid History</a>
                    </div>
                    <div class="flex flex-col mx-auto md:grid md:grid-cols-2 md:gap-6 md:px-5 lg:pt-6 xl:grid-cols-[minmax(0,_1fr)_minmax(0,_1fr)_minmax(0,_0.6fr)] xl:max-w-screen-3xl 3xl:px-2 wide:px-0">
                        <div class="px-4 pb-4 md:px-0 md:pb-0 col-start-1 row-start-1 md:col-start-2">
                            <h1 class="text-left capitalize font-bold  bg-white md:p-4 md:shadow-md md:rounded-itemCard text-title-sm md:text-title-md">Speediance Gym Monster 2 Smart Home Gym, Upgraded AI-Powered Home Workout Machine, Multi-Functional Smith Machine, Full Body Strength Training Fitness Equipment, All-in-One Workout Station</h1>
                        </div>
                        <div class="md:col-start-1 md:row-start-1 md:row-span-4 xl:row-span-5">
                            <div class="scroll-mt-56" id="photos">
                                <div class="overflow-x-auto md:overflow-visible scrollbar-none bg-white md:bg-neutral-100">
                                    <div class="flex gap-4 md:gap-6 lg:gap-8 md:flex-col aspect-[16/11] md:aspect-[1/1] px-4 md:px-0">
                                        <div class="relative flex-shrink-0 md:w-full border border-neutral-200 md:border-none rounded-itemCard p-4 md:p-0 w-[325px]">
                                            <img src="https://images-na.ssl-images-amazon.com/images/I/61s+dEzQFTL.jpg" alt="Photo 1 of Speediance Gym Monster 2 Smart Home Gym, Upgraded AI-Powered Home Workout Machine, Multi-Functional Smith Machine, Full Body Strength Training Fitness Equipment, All-in-One Workout Station" class="object-contain w-full h-full rounded-itemCard"/>
                                            <div class="bg-gray-600 opacity-80 text-white p-2.5 rounded-full absolute left-3 z-10 bottom-2 md:top-2 md:bottom-auto">1/3</div>
                                            <a aria-label="View image in fullscreen" data-ax="product-page-expand-image-button" class="absolute right-3 bottom-2 md:top-2 md:bottom-auto bg-gray-600 hover:bg-gray-800 opacity-80 p-2.5 rounded-full cursor-pointer focus-within:outline-secondary" data-discover="true" href="/p/Speediance-Gym-Monster-2-Smart-Home-Gym-Upgraded-AI-Powered-Home/50504133/1">
                                                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512" height="24" width="24" class="fill-white">
                                                    <path d="M321 0c-18.2 0-33 14.8-33 33c0 8.7 3.5 17.1 9.7 23.3L325.4 84l-71.7 71.7c-15.6 15.6-15.6 40.9 0 56.6l46.1 46.1c15.6 15.6 40.9 15.6 56.6 0L428 186.6l27.7 27.7c6.2 6.2 14.6 9.7 23.3 9.7c18.2 0 33-14.8 33-33l0-159c0-17.7-14.3-32-32-32L321 0zm-1 33c0-.5 .4-1 1-1l159 0 0 159c0 .5-.4 1-1 1c-.3 0-.5-.1-.7-.3l-39-39c-6.2-6.2-16.4-6.2-22.6 0l-83 83c-3.1 3.1-8.2 3.1-11.3 0l-46.1-46.1c-3.1-3.1-3.1-8.2 0-11.3l83-83c3-3 4.7-7.1 4.7-11.3s-1.7-8.3-4.7-11.3l-39-39c-.2-.2-.3-.4-.3-.7zM32 512l159 0c18.2 0 33-14.8 33-33c0-8.7-3.5-17.1-9.7-23.3L186.6 428l71.7-71.7c15.6-15.6 15.6-40.9 0-56.6l-46.1-46.1c-15.6-15.6-40.9-15.6-56.6 0L84 325.4 56.3 297.7C50.1 291.5 41.7 288 33 288c-18.2 0-33 14.8-33 33L0 480c0 17.7 14.3 32 32 32zm160-33c0 .5-.4 1-1 1L32 480l0-159c0-.5 .4-1 1-1c.3 0 .5 .1 .7 .3l39 39c6.2 6.2 16.4 6.2 22.6 0l83-83c3.1-3.1 8.2-3.1 11.3 0l46.1 46.1c3.1 3.1 3.1 8.2 0 11.3l-83 83c-3 3-4.7 7.1-4.7 11.3s1.7 8.3 4.7 11.3l39 39c.2 .2 .3 .4 .3 .7z"></path>
                                                </svg>
                                            </a>
                                        </div>
                                        <div class="relative flex-shrink-0 md:w-full border border-neutral-200 md:border-none rounded-itemCard p-4 md:p-0 w-[325px]">
                                            <img src="https://firebasestorage.googleapis.com/v0/b/nellishr-cbba0.appspot.com/o/processing-photos%2F1037519722%2FNNLastRxUi6UDeywWGHH0.jpeg?alt=media&amp;token=ab59f573-17a4-4248-b08a-a06f3c26fdb2" alt="Photo 1 of Speediance Gym Monster 2 Smart Home Gym, Upgraded AI-Powered Home Workout Machine, Multi-Functional Smith Machine, Full Body Strength Training Fitness Equipment, All-in-One Workout Station" class="object-contain w-full h-full rounded-itemCard"/>
                                            <div class="bg-gray-600 opacity-80 text-white p-2.5 rounded-full absolute left-3 z-10 bottom-2 md:top-2 md:bottom-auto">2/3</div>
                                            <a aria-label="View image in fullscreen" data-ax="product-page-expand-image-button" class="absolute right-3 bottom-2 md:top-2 md:bottom-auto bg-gray-600 hover:bg-gray-800 opacity-80 p-2.5 rounded-full cursor-pointer focus-within:outline-secondary" data-discover="true" href="/p/Speediance-Gym-Monster-2-Smart-Home-Gym-Upgraded-AI-Powered-Home/50504133/2">
                                                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512" height="24" width="24" class="fill-white">
                                                    <path d="M321 0c-18.2 0-33 14.8-33 33c0 8.7 3.5 17.1 9.7 23.3L325.4 84l-71.7 71.7c-15.6 15.6-15.6 40.9 0 56.6l46.1 46.1c15.6 15.6 40.9 15.6 56.6 0L428 186.6l27.7 27.7c6.2 6.2 14.6 9.7 23.3 9.7c18.2 0 33-14.8 33-33l0-159c0-17.7-14.3-32-32-32L321 0zm-1 33c0-.5 .4-1 1-1l159 0 0 159c0 .5-.4 1-1 1c-.3 0-.5-.1-.7-.3l-39-39c-6.2-6.2-16.4-6.2-22.6 0l-83 83c-3.1 3.1-8.2 3.1-11.3 0l-46.1-46.1c-3.1-3.1-3.1-8.2 0-11.3l83-83c3-3 4.7-7.1 4.7-11.3s-1.7-8.3-4.7-11.3l-39-39c-.2-.2-.3-.4-.3-.7zM32 512l159 0c18.2 0 33-14.8 33-33c0-8.7-3.5-17.1-9.7-23.3L186.6 428l71.7-71.7c15.6-15.6 15.6-40.9 0-56.6l-46.1-46.1c-15.6-15.6-40.9-15.6-56.6 0L84 325.4 56.3 297.7C50.1 291.5 41.7 288 33 288c-18.2 0-33 14.8-33 33L0 480c0 17.7 14.3 32 32 32zm160-33c0 .5-.4 1-1 1L32 480l0-159c0-.5 .4-1 1-1c.3 0 .5 .1 .7 .3l39 39c6.2 6.2 16.4 6.2 22.6 0l83-83c3.1-3.1 8.2-3.1 11.3 0l46.1 46.1c3.1 3.1 3.1 8.2 0 11.3l-83 83c-3 3-4.7 7.1-4.7 11.3s1.7 8.3 4.7 11.3l39 39c.2 .2 .3 .4 .3 .7z"></path>
                                                </svg>
                                            </a>
                                        </div>
                                        <div class="relative flex-shrink-0 md:w-full border border-neutral-200 md:border-none rounded-itemCard p-4 md:p-0 w-[325px]">
                                            <img src="https://firebasestorage.googleapis.com/v0/b/nellishr-cbba0.appspot.com/o/processing-photos%2F1037519722%2F5-zKtjO1cy0wldRFiPnR5.jpeg?alt=media&amp;token=8f1dd1f6-8cad-4766-b2ef-25870853df79" alt="Photo 1 of Speediance Gym Monster 2 Smart Home Gym, Upgraded AI-Powered Home Workout Machine, Multi-Functional Smith Machine, Full Body Strength Training Fitness Equipment, All-in-One Workout Station" class="object-contain w-full h-full rounded-itemCard"/>
                                            <div class="bg-gray-600 opacity-80 text-white p-2.5 rounded-full absolute left-3 z-10 bottom-2 md:top-2 md:bottom-auto">3/3</div>
                                            <a aria-label="View image in fullscreen" data-ax="product-page-expand-image-button" class="absolute right-3 bottom-2 md:top-2 md:bottom-auto bg-gray-600 hover:bg-gray-800 opacity-80 p-2.5 rounded-full cursor-pointer focus-within:outline-secondary" data-discover="true" href="/p/Speediance-Gym-Monster-2-Smart-Home-Gym-Upgraded-AI-Powered-Home/50504133/3">
                                                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512" height="24" width="24" class="fill-white">
                                                    <path d="M321 0c-18.2 0-33 14.8-33 33c0 8.7 3.5 17.1 9.7 23.3L325.4 84l-71.7 71.7c-15.6 15.6-15.6 40.9 0 56.6l46.1 46.1c15.6 15.6 40.9 15.6 56.6 0L428 186.6l27.7 27.7c6.2 6.2 14.6 9.7 23.3 9.7c18.2 0 33-14.8 33-33l0-159c0-17.7-14.3-32-32-32L321 0zm-1 33c0-.5 .4-1 1-1l159 0 0 159c0 .5-.4 1-1 1c-.3 0-.5-.1-.7-.3l-39-39c-6.2-6.2-16.4-6.2-22.6 0l-83 83c-3.1 3.1-8.2 3.1-11.3 0l-46.1-46.1c-3.1-3.1-3.1-8.2 0-11.3l83-83c3-3 4.7-7.1 4.7-11.3s-1.7-8.3-4.7-11.3l-39-39c-.2-.2-.3-.4-.3-.7zM32 512l159 0c18.2 0 33-14.8 33-33c0-8.7-3.5-17.1-9.7-23.3L186.6 428l71.7-71.7c15.6-15.6 15.6-40.9 0-56.6l-46.1-46.1c-15.6-15.6-40.9-15.6-56.6 0L84 325.4 56.3 297.7C50.1 291.5 41.7 288 33 288c-18.2 0-33 14.8-33 33L0 480c0 17.7 14.3 32 32 32zm160-33c0 .5-.4 1-1 1L32 480l0-159c0-.5 .4-1 1-1c.3 0 .5 .1 .7 .3l39 39c6.2 6.2 16.4 6.2 22.6 0l83-83c3.1-3.1 8.2-3.1 11.3 0l46.1 46.1c3.1 3.1 3.1 8.2 0 11.3l-83 83c-3 3-4.7 7.1-4.7 11.3s1.7 8.3 4.7 11.3l39 39c.2 .2 .3 .4 .3 .7z"></path>
                                                </svg>
                                            </a>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="md:col-start-2 md:row-start-2 xl:col-start-3 xl:row-start-1 xl:sticky xl:row-span-4">
                            <div id="bid-section" class="z-10 bg-white shadow-lg my-4 grid md:my-0 xl:sticky xl:top-36 md:rounded-itemCard md:gap-2.5 scroll-mt-56 bid-message-slide-up">
                                <div class="px-4 py-2 md:py-4 flex items-center justify-center gap-4 md:rounded-t-itemCard border-x border-t md:border-b">
                                    <div class="h-full py-2 flex-1 flex flex-col items-center justify-center rounded-[0.625rem] bg-neutral-200" data-ax="item-card-time-countdown-container">
                                        <p class="relative text-body-sm font-bold uppercase text-gray-900 w-full text-center">
                                            <strong class="">Time Left</strong>
                                        </p>
                                        <p class="text-gray-900 font-semibold line-clamp-1 text-label-sm xxs:text-title-xs xs:text-label-md sm:text-title-xs md:text-title-sm lg:text-title-md xl:text-title-sm xxl:text-title-xs">5 hours</p>
                                    </div>
                                    <div class="h-full py-2 flex-1 flex flex-col items-center justify-center rounded-[0.625rem] bg-neutral-200 ">
                                        <p class="relative text-body-sm font-bold uppercase text-gray-900 w-full text-center">
                                            <strong class="">CURRENT PRICE</strong>
                                        </p>
                                        <p class="text-gray-900 font-semibold line-clamp-1 text-label-sm xxs:text-title-xs xs:text-label-md sm:text-title-xs md:text-title-sm lg:text-title-md xl:text-title-sm xxl:text-title-xs">$503</p>
                                    </div>
                                </div>
                                <hr class="hidden"/>
                                <div class="px-2.5">
                                    <a class="relative block w-fit text-body-lg font-semibold rounded-[3px] py-2 px-4 bg-gradient-to-r from-primary to-[#93291E]
    hover:from-sincity-red-800 hover:to-[#7D0000]
    focus:to-[#7D0000] focus:outline focus:outline-[3px] focus:outline-[#F397A2]
    disabled:from-gray-900 disabled:to-neutral-600 w-full mb-4 rounded-lg" data-ax="product-page-login-to-bid-link" data-discover="true" href="/login?redirect=/p/Speediance-Gym-Monster-2-Smart-Home-Gym-Upgraded-AI-Powered-Home/50504133?index">
                                        <span class="flex items-center justify-center opacity-100 text-white">LOGIN TO BID</span>
                                    </a>
                                </div>
                            </div>
                        </div>
                        <div class="xl:col-start-2">
                            <div class="md:rounded-itemCard md:shadow-md bg-white p-4 col-start-2 scroll-mt-56" id="item-details">
                                <h4 class="text-left font-semibold mb-1 text-title-xs">Item Details</h4>
                                <div class="flex flex-col gap-5">
                                    <div class="flex flex-col text-left">
                                        <p class="text-left font-medium">Auction closes</p>
                                        <p>April 29, 2025 at 1:26 AM</p>
                                    </div>
                                    <div>
                                        <p class="text-left font-medium">Quality</p>
                                        <div class="flex items-center gap-2 justify-start mt-2 mb-3">
                                            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 576 512" class="fill-starRating-5" width="24" height="24">
                                                <path d="M316.9 18c-5.3-11-16.5-18-28.8-18s-23.4 7-28.8 18L195 150.3 51.4 171.5c-12 1.8-22 10.2-25.7 21.7s-.7 24.2 7.9 32.7L137.8 329l-24.6 145.7c-2 12 3 24.2 12.9 31.3s23 8 33.8 2.3l128.3-68.5 128.3 68.5c10.8 5.7 23.9 4.9 33.8-2.3s14.9-19.3 12.9-31.3L438.5 329l104.2-103.1c8.6-8.5 11.7-21.2 7.9-32.7s-13.7-19.9-25.7-21.7l-143.7-21.2L316.9 18z"></path>
                                            </svg>
                                            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 576 512" class="fill-starRating-5" width="24" height="24">
                                                <path d="M316.9 18c-5.3-11-16.5-18-28.8-18s-23.4 7-28.8 18L195 150.3 51.4 171.5c-12 1.8-22 10.2-25.7 21.7s-.7 24.2 7.9 32.7L137.8 329l-24.6 145.7c-2 12 3 24.2 12.9 31.3s23 8 33.8 2.3l128.3-68.5 128.3 68.5c10.8 5.7 23.9 4.9 33.8-2.3s14.9-19.3 12.9-31.3L438.5 329l104.2-103.1c8.6-8.5 11.7-21.2 7.9-32.7s-13.7-19.9-25.7-21.7l-143.7-21.2L316.9 18z"></path>
                                            </svg>
                                            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 576 512" class="fill-starRating-5" width="24" height="24">
                                                <path d="M316.9 18c-5.3-11-16.5-18-28.8-18s-23.4 7-28.8 18L195 150.3 51.4 171.5c-12 1.8-22 10.2-25.7 21.7s-.7 24.2 7.9 32.7L137.8 329l-24.6 145.7c-2 12 3 24.2 12.9 31.3s23 8 33.8 2.3l128.3-68.5 128.3 68.5c10.8 5.7 23.9 4.9 33.8-2.3s14.9-19.3 12.9-31.3L438.5 329l104.2-103.1c8.6-8.5 11.7-21.2 7.9-32.7s-13.7-19.9-25.7-21.7l-143.7-21.2L316.9 18z"></path>
                                            </svg>
                                            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 576 512" class="fill-starRating-5" width="24" height="24">
                                                <path d="M316.9 18c-5.3-11-16.5-18-28.8-18s-23.4 7-28.8 18L195 150.3 51.4 171.5c-12 1.8-22 10.2-25.7 21.7s-.7 24.2 7.9 32.7L137.8 329l-24.6 145.7c-2 12 3 24.2 12.9 31.3s23 8 33.8 2.3l128.3-68.5 128.3 68.5c10.8 5.7 23.9 4.9 33.8-2.3s14.9-19.3 12.9-31.3L438.5 329l104.2-103.1c8.6-8.5 11.7-21.2 7.9-32.7s-13.7-19.9-25.7-21.7l-143.7-21.2L316.9 18z"></path>
                                            </svg>
                                            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 576 512" class="fill-starRating-5" width="24" height="24">
                                                <path d="M316.9 18c-5.3-11-16.5-18-28.8-18s-23.4 7-28.8 18L195 150.3 51.4 171.5c-12 1.8-22 10.2-25.7 21.7s-.7 24.2 7.9 32.7L137.8 329l-24.6 145.7c-2 12 3 24.2 12.9 31.3s23 8 33.8 2.3l128.3-68.5 128.3 68.5c10.8 5.7 23.9 4.9 33.8-2.3s14.9-19.3 12.9-31.3L438.5 329l104.2-103.1c8.6-8.5 11.7-21.2 7.9-32.7s-13.7-19.9-25.7-21.7l-143.7-21.2L316.9 18z"></path>
                                            </svg>
                                        </div>
                                        <div class="flex items-center justify-start gap-2 flex-wrap">
                                            <div class="max-w-100 whitespace-nowrap flex items-center justify-center h-8 bg-emerald-100 text-gray-800 rounded-lg">
                                                <span class="px-3 whitespace-nowrap overflow-hidden text-ellipsis">New</span>
                                            </div>
                                            <div class="max-w-100 whitespace-nowrap flex items-center justify-center h-8 bg-emerald-100 text-gray-800 rounded-lg">
                                                <span class="px-3 whitespace-nowrap overflow-hidden text-ellipsis">Functional</span>
                                            </div>
                                            <div class="max-w-100 whitespace-nowrap flex items-center justify-center h-8 bg-emerald-100 text-gray-800 rounded-lg">
                                                <span class="px-3 whitespace-nowrap overflow-hidden text-ellipsis">No Damage</span>
                                            </div>
                                            <div class="max-w-100 whitespace-nowrap flex items-center justify-center h-8 bg-sincity-red-100 text-gray-800 rounded-lg">
                                                <span class="px-3 whitespace-nowrap overflow-hidden text-ellipsis">Assembly Required</span>
                                            </div>
                                            <div class="max-w-100 whitespace-nowrap flex items-center justify-center h-8 bg-emerald-100 text-gray-800 rounded-lg">
                                                <span class="px-3 whitespace-nowrap overflow-hidden text-ellipsis">In Package</span>
                                            </div>
                                            <div class="max-w-100 whitespace-nowrap flex items-center justify-center h-8 bg-emerald-100 text-gray-800 rounded-lg">
                                                <span class="px-3 whitespace-nowrap overflow-hidden text-ellipsis">No Missing Parts</span>
                                            </div>
                                        </div>
                                    </div>
                                    <div>
                                        <p class="text-left font-medium">Local Pickup</p>
                                        <div class="text-left flex flex-col">
                                            <p>3615 W Grand Pkwy N</p>
                                            <p>Katy, TX, 77449</p>
                                        </div>
                                    </div>
                                    <div class="flex flex-col text-left">
                                        <p class="text-left font-medium">Estimated Retail Price</p>
                                        <p>$4200.00</p>
                                    </div>
                                    <div class="flex flex-col text-left">
                                        <p class="text-left font-medium">Buyers Premium</p>
                                        <p>15%</p>
                                    </div>
                                    <div class="flex flex-col text-left">
                                        <p class="text-left font-medium">Inventory Number</p>
                                        <p>1037519722</p>
                                    </div>
                                    <div class="flex flex-col text-left">
                                        <p class="text-left font-medium">Category</p>
                                        <div class="flex flex-col gap-2">
                                            <a class="flex items-center gap-1 text-secondary focus-within:outline-secondary hover:underline hover:text-secondary-light w-fit" data-discover="true" href="/search?Taxonomy+Level+1=Outdoors+%26+Sports">
                                                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 448 512" class="fill-secondary" width="16" height="16">
                                                    <path d="M443.3 267.3c6.2-6.2 6.2-16.4 0-22.6l-176-176c-6.2-6.2-16.4-6.2-22.6 0s-6.2 16.4 0 22.6L393.4 240 16 240c-8.8 0-16 7.2-16 16s7.2 16 16 16l377.4 0L244.7 420.7c-6.2 6.2-6.2 16.4 0 22.6s16.4 6.2 22.6 0l176-176z"></path>
                                                </svg>
                                                Outdoors &amp;Sports
                                            </a>
                                            <a class="flex items-center gap-1 text-secondary focus-within:outline-secondary hover:underline hover:text-secondary-light w-fit ml-6" data-discover="true" href="/search?Taxonomy+Level+1=Outdoors+%26+Sports&amp;Taxonomy+Level+2=Outdoor+Recreation">
                                                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512" height="16" width="16" class="fill-secondary">
                                                    <path d="M32 48c0-8.8-7.2-16-16-16S0 39.2 0 48L0 224c0 44.2 35.8 80 80 80l377.4 0L356.7 404.7c-6.2 6.2-6.2 16.4 0 22.6s16.4 6.2 22.6 0l128-128c6.2-6.2 6.2-16.4 0-22.6l-128-128c-6.2-6.2-16.4-6.2-22.6 0s-6.2 16.4 0 22.6L457.4 272 80 272c-26.5 0-48-21.5-48-48L32 48z"></path>
                                                </svg>
                                                Outdoor Recreation
                                            </a>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="md:col-span-2 xl:col-start-2 xl:col-span-1">
                            <div class="grid grid-cols-1 overflow-hidden border-t border-neutral-300 lg:rounded-2xl lg:shadow-bold lg:border-t-none lg:grid-cols-2 lg:col-span-2 lg:px-5 pt-5 gap-5 md:shadow-md md:rounded-itemCard bg-white [&amp;_a]:mb-5">
                                <div class="flex justify-center lg:px-7 lg:pt-7 lg:bg-CT-video-gradient lg:col-start-2 rounded-t-itemCard">
                                    <img src="/assets/images/CT-video-tutorial-mobile.png" alt="Video Tutorials page screenshot" class="lg:hidden rounded-t-itemCard shadow-bold"/>
                                    <img src="/assets/images/CT-video-tutorial-desktop.png" alt="Video Tutorials page screenshot" class="hidden lg:block shadow-bold"/>
                                </div>
                                <div class="flex flex-col items-center lg:items-start text-center lg:text-left col-start-1 row-start-1 justify-center px-4 lg:px-0 py-7 lg:py-0">
                                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 384 512" class="mb-4" width="32" height="32">
                                        <path d="M56.3 66.3c-4.9-3-11.1-3.1-16.2-.3s-8.2 8.2-8.2 14l0 352c0 5.8 3.1 11.1 8.2 14s11.2 2.7 16.2-.3l288-176c4.8-2.9 7.7-8.1 7.7-13.7s-2.9-10.7-7.7-13.7l-288-176zM24.5 38.1C39.7 29.6 58.2 30 73 39L361 215c14.3 8.7 23 24.2 23 41s-8.7 32.2-23 41L73 473c-14.8 9.1-33.4 9.4-48.5 .9S0 449.4 0 432L0 80C0 62.6 9.4 46.6 24.5 38.1z"></path>
                                    </svg>
                                    <p class="font-semibold mt-2">Getting Started</p>
                                    <p class="mb-2">Learn more about bidding, winning, pickup, and more on our video tutorials page.</p>
                                    <a aria-label="Visit Video Tutorials" class="text-secondary flex gap-1.5 items-center focus-within:outline-secondary hover:underline" data-discover="true" href="/help">
                                        <p>Visit Video Tutorials</p>
                                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 448 512" class="fill-secondary" width="20" height="20">
                                            <path d="M443.3 267.3c6.2-6.2 6.2-16.4 0-22.6l-176-176c-6.2-6.2-16.4-6.2-22.6 0s-6.2 16.4 0 22.6L393.4 240 16 240c-8.8 0-16 7.2-16 16s7.2 16 16 16l377.4 0L244.7 420.7c-6.2 6.2-6.2 16.4 0 22.6s16.4 6.2 22.6 0l176-176z"></path>
                                        </svg>
                                    </a>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </main>
            <footer>
                <div class="mb-20 lg:mb-0">
                    <div class="m-auto pt-[1.125rem] pb-10 ">
                        <div class="flex justify-center items-center gap-4 overflow-hidden whitespace-nowrap my-0 md:mb-1 lg:mb-3">
                            <hr class="__divider-base"/>
                            <strong class="font-semibold text-body-lg text-gray-700">CONTACT US</strong>
                            <hr class="__divider-base"/>
                        </div>
                        <div class="flex flex-col md:flex-row items-center justify-center gap-y-3 md:gap-x-5">
                            <div class="text-center pt-7 pb-[1.313rem] last:pb-0 md:pb-0 md:w-60 flex flex-col gap-y-3 lg:gap-y-6">
                                <div class="flex items-center justify-center">
                                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512" width="28" height="28" class="fill-burgundy-900">
                                        <path d="M256 512A256 256 0 1 0 256 0a256 256 0 1 0 0 512zM169.8 165.3c7.9-22.3 29.1-37.3 52.8-37.3h58.3c34.9 0 63.1 28.3 63.1 63.1c0 22.6-12.1 43.5-31.7 54.8L280 264.4c-.2 13-10.9 23.6-24 23.6c-13.3 0-24-10.7-24-24V250.5c0-8.6 4.6-16.5 12.1-20.8l44.3-25.4c4.7-2.7 7.6-7.7 7.6-13.1c0-8.4-6.8-15.1-15.1-15.1H222.6c-3.4 0-6.4 2.1-7.5 5.3l-.4 1.2c-4.4 12.5-18.2 19-30.6 14.6s-19-18.2-14.6-30.6l.4-1.2zM224 352a32 32 0 1 1 64 0 32 32 0 1 1 -64 0z"></path>
                                    </svg>
                                </div>
                                <div>
                                    <p class="text-body-lg text-gray-900">Help Center</p>
                                    <p class="text-label-lg text-gray-900">
                                        <a rel="noopener noreferrer" class="text-secondary underline hover:text-secondary-light" href="https://nellisauction.help" target="_blank">nellisauction.help</a>
                                    </p>
                                </div>
                            </div>
                            <div class="text-center pt-7 pb-[1.313rem] last:pb-0 md:pb-0 md:w-60 flex flex-col gap-y-3 lg:gap-y-6">
                                <div class="flex items-center justify-center">
                                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 28 28" width="28" height="28" class="fill-burgundy-900">
                                        <path d="M14 1.75C7.23516 1.75 1.75 7.23516 1.75 14C1.75 20.7648 7.23516 26.25 14 26.25C14.4812 26.25 14.875 26.6437 14.875 27.125C14.875 27.6063 14.4812 28 14 28C6.26719 28 0 21.7328 0 14C0 6.26719 6.26719 0 14 0C21.7328 0 28 6.26719 28 14V15.3125C28 17.9703 25.8453 20.125 23.1875 20.125C21.3609 20.125 19.7695 19.1023 18.9547 17.6039C17.8391 19.1352 16.0344 20.125 14 20.125C10.6148 20.125 7.875 17.3852 7.875 14C7.875 10.6148 10.6148 7.875 14 7.875C15.7117 7.875 17.2648 8.58047 18.375 9.7125V9.625C18.375 9.14375 18.7687 8.75 19.25 8.75C19.7313 8.75 20.125 9.14375 20.125 9.625V14V15.3125C20.125 17.0023 21.4977 18.375 23.1875 18.375C24.8773 18.375 26.25 17.0023 26.25 15.3125V14C26.25 7.23516 20.7648 1.75 14 1.75ZM18.375 14C18.375 12.8397 17.9141 11.7269 17.0936 10.9064C16.2731 10.0859 15.1603 9.625 14 9.625C12.8397 9.625 11.7269 10.0859 10.9064 10.9064C10.0859 11.7269 9.625 12.8397 9.625 14C9.625 15.1603 10.0859 16.2731 10.9064 17.0936C11.7269 17.9141 12.8397 18.375 14 18.375C15.1603 18.375 16.2731 17.9141 17.0936 17.0936C17.9141 16.2731 18.375 15.1603 18.375 14Z"></path>
                                    </svg>
                                </div>
                                <div>
                                    <p class="text-body-lg text-gray-900">Email</p>
                                    <p class="text-label-lg text-gray-900">info@nellisauction.com</p>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="bg-neutral-800">
                        <div class="py-10 m-auto max-w-screen-3xl flex flex-col gap-12 justify-between lg:gap-0 lg:flex-row lg:py-9 lg:px-5 wide:px-0">
                            <div class="flex flex-col items-center lg:items-start lg:flex-row gap-12 md:gap-14 lg:gap-16">
                                <ul class="lg:min-w-48 flex flex-col items-center lg:items-start justify-center">
                                    <li class="text-label-md font-bold text-white">Company</li>
                                    <li>
                                        <a aria-label="Accessibility" data-discover="true" href="/accessibility-statement">
                                            <p class="mt-5 text-label-lg text-white font-light underline decoration-from-font lg:no-underline lg:text-label-md hover:underline">Accessibility</p>
                                        </a>
                                    </li>
                                    <li>
                                        <a aria-label="Careers" data-discover="true" href="/careers">
                                            <p class="mt-5 text-label-lg text-white font-light underline decoration-from-font lg:no-underline lg:text-label-md hover:underline">Careers</p>
                                        </a>
                                    </li>
                                    <li>
                                        <a aria-label="Location &amp; Hours" data-discover="true" href="/location-hours">
                                            <p class="mt-5 text-label-lg text-white font-light underline decoration-from-font lg:no-underline lg:text-label-md hover:underline">Location &amp;Hours</p>
                                        </a>
                                    </li>
                                </ul>
                                <ul class="lg:min-w-48 flex flex-col items-center lg:items-start justify-center">
                                    <li class="text-label-md font-bold text-white">Services</li>
                                    <li>
                                        <a aria-label="Estate Sales" data-discover="true" href="/estate-sales">
                                            <p class="mt-5 text-label-lg text-white font-light underline decoration-from-font lg:no-underline lg:text-label-md hover:underline">Estate Sales</p>
                                        </a>
                                    </li>
                                </ul>
                                <ul class="lg:min-w-48 flex flex-col items-center lg:items-start justify-center">
                                    <li class="text-label-md font-bold text-white">Help Center</li>
                                    <li>
                                        <a aria-label="Video Tutorials" data-discover="true" href="/help">
                                            <p class="mt-5 text-label-lg text-white font-light underline decoration-from-font lg:no-underline lg:text-label-md hover:underline">Video Tutorials</p>
                                        </a>
                                    </li>
                                    <li>
                                        <a aria-label="FAQ" data-discover="true" href="/faq">
                                            <p class="mt-5 text-label-lg text-white font-light underline decoration-from-font lg:no-underline lg:text-label-md hover:underline">FAQ</p>
                                        </a>
                                    </li>
                                </ul>
                            </div>
                            <div class="flex items-center justify-center gap-12 self-center lg:justify-end px-8 lg:px-0 ">
                                <a aria-label="Nellis Auction Facebook page" href="https://www.facebook.com/NellisAuction" target="_blank" rel="noreferrer">
                                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512" width="32" height="32" class="fill-white">
                                        <path d="M512 256C512 114.6 397.4 0 256 0S0 114.6 0 256C0 376 82.7 476.8 194.2 504.5V334.2H141.4V256h52.8V222.3c0-87.1 39.4-127.5 125-127.5c16.2 0 44.2 3.2 55.7 6.4V172c-6-.6-16.5-1-29.6-1c-42 0-58.2 15.9-58.2 57.2V256h83.6l-14.4 78.2H287V510.1C413.8 494.8 512 386.9 512 256h0z"></path>
                                    </svg>
                                    <span class="sr-only">Facebook</span>
                                </a>
                                <a aria-label="Nellis Auction Instagram page" href="https://www.instagram.com/nellisauction" target="_blank" rel="noreferrer">
                                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 448 512" width="32" height="32" class="fill-white">
                                        <path d="M224.1 141c-63.6 0-114.9 51.3-114.9 114.9s51.3 114.9 114.9 114.9S339 319.5 339 255.9 287.7 141 224.1 141zm0 189.6c-41.1 0-74.7-33.5-74.7-74.7s33.5-74.7 74.7-74.7 74.7 33.5 74.7 74.7-33.6 74.7-74.7 74.7zm146.4-194.3c0 14.9-12 26.8-26.8 26.8-14.9 0-26.8-12-26.8-26.8s12-26.8 26.8-26.8 26.8 12 26.8 26.8zm76.1 27.2c-1.7-35.9-9.9-67.7-36.2-93.9-26.2-26.2-58-34.4-93.9-36.2-37-2.1-147.9-2.1-184.9 0-35.8 1.7-67.6 9.9-93.9 36.1s-34.4 58-36.2 93.9c-2.1 37-2.1 147.9 0 184.9 1.7 35.9 9.9 67.7 36.2 93.9s58 34.4 93.9 36.2c37 2.1 147.9 2.1 184.9 0 35.9-1.7 67.7-9.9 93.9-36.2 26.2-26.2 34.4-58 36.2-93.9 2.1-37 2.1-147.8 0-184.8zM398.8 388c-7.8 19.6-22.9 34.7-42.6 42.6-29.5 11.7-99.5 9-132.1 9s-102.7 2.6-132.1-9c-19.6-7.8-34.7-22.9-42.6-42.6-11.7-29.5-9-99.5-9-132.1s-2.6-102.7 9-132.1c7.8-19.6 22.9-34.7 42.6-42.6 29.5-11.7 99.5-9 132.1-9s102.7-2.6 132.1 9c19.6 7.8 34.7 22.9 42.6 42.6 11.7 29.5 9 99.5 9 132.1s2.7 102.7-9 132.1z"></path>
                                    </svg>
                                    <span class="sr-only">Instagram</span>
                                </a>
                                <a aria-label="Nellis Auction Linkedin page" href="https://www.linkedin.com/company/nellis-auction" target="_blank" rel="noreferrer">
                                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 448 512" width="32" height="32" class="fill-white">
                                        <path d="M416 32H31.9C14.3 32 0 46.5 0 64.3v383.4C0 465.5 14.3 480 31.9 480H416c17.6 0 32-14.5 32-32.3V64.3c0-17.8-14.4-32.3-32-32.3zM135.4 416H69V202.2h66.5V416zm-33.2-243c-21.3 0-38.5-17.3-38.5-38.5S80.9 96 102.2 96c21.2 0 38.5 17.3 38.5 38.5 0 21.3-17.2 38.5-38.5 38.5zm282.1 243h-66.4V312c0-24.8-.5-56.7-34.5-56.7-34.6 0-39.9 27-39.9 54.9V416h-66.4V202.2h63.7v29.2h.9c8.9-16.8 30.6-34.5 62.9-34.5 67.2 0 79.7 44.3 79.7 101.9V416z"></path>
                                    </svg>
                                    <span class="sr-only">LinkedIn</span>
                                </a>
                                <a aria-label="Nellis Auction Youtube page" href="https://www.youtube.com/@nellisauction" target="_blank" rel="noreferrer">
                                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 576 512" width="32" height="32" class="fill-white">
                                        <path d="M549.7 124.1c-6.3-23.7-24.8-42.3-48.3-48.6C458.8 64 288 64 288 64S117.2 64 74.6 75.5c-23.5 6.3-42 24.9-48.3 48.6-11.4 42.9-11.4 132.3-11.4 132.3s0 89.4 11.4 132.3c6.3 23.7 24.8 41.5 48.3 47.8C117.2 448 288 448 288 448s170.8 0 213.4-11.5c23.5-6.3 42-24.2 48.3-47.8 11.4-42.9 11.4-132.3 11.4-132.3s0-89.4-11.4-132.3zm-317.5 213.5V175.2l142.7 81.2-142.7 81.2z"></path>
                                    </svg>
                                    <span class="sr-only">YouTube</span>
                                </a>
                            </div>
                        </div>
                    </div>
                    <div class="border-t border-solid bg-neutral-900">
                        <div class="m-auto py-10 lg:py-6 lg:px-5 wide:px-0 max-w-screen-3xl flex flex-col lg:flex-row justify-between gap-3">
                            <div class="flex flex-col lg:flex-row items-center justify-center gap-3">
                                <a class="text-label-md font-semibold text-white break-words" data-discover="true" href="/terms">Terms &amp;Conditions</a>
                                <span class="hidden text-white mx-1 lg:inline">|</span>
                                <a class="text-label-md font-semibold text-white break-words " data-discover="true" href="/privacy">Privacy Policy</a>
                                <span class="hidden text-white mx-1 lg:inline">|</span>
                                <a class="text-label-md font-semibold text-white break-words " data-discover="true" href="/browse">Browse Auctions</a>
                            </div>
                            <p class="text-label-md font-semibold text-white text-center">
                                © Copyright 
                                <!-- -->
                                2025
                                <!-- -->
                                <a href="https://www.nellisauction.com/">nellisauction.com</a>
                            </p>
                        </div>
                    </div>
                    <div data-ax="mobile-sticky-footer" class="px-3 pt-2 pb-4 lg:hidden fixed right-0 bottom-0 left-0 z-10 bg-white h-20">
                        <div class="m-auto max-w-96 grid grid-cols-4 justify-items-center">
                            <div class="flex lg:hidden">
                                <label aria-label="location selector" id="location-selector" class="group relative w-full cursor-pointer bg-white focus:outline-secondary focus-visible:outline-none" tabindex="0">
                                    <input aria-labelledby="location-selector" type="checkbox" class="hidden"/>
                                    <div class="px-2 flex flex-col text-left items-center">
                                        <div class="flex p-2 rounded-3xl group-has-[:checked]:bg-burgundy-50">
                                            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 384 512" class="fill-burgundy-900 hidden group-has-[:checked]:block" width="22" height="22">
                                                <path d="M215.7 499.2C267 435 384 279.4 384 192C384 86 298 0 192 0S0 86 0 192c0 87.4 117 243 168.3 307.2c12.3 15.3 35.1 15.3 47.4 0zM192 128a64 64 0 1 1 0 128 64 64 0 1 1 0-128z"></path>
                                            </svg>
                                            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 384 512" class="flex fill-burgundy-900 group-has-[:checked]:hidden" width="22" height="22">
                                                <path d="M352 192c0-88.4-71.6-160-160-160S32 103.6 32 192c0 15.6 5.4 37 16.6 63.4c10.9 25.9 26.2 54 43.6 82.1c34.1 55.3 74.4 108.2 99.9 140c25.4-31.8 65.8-84.7 99.9-140c17.3-28.1 32.7-56.3 43.6-82.1C346.6 229 352 207.6 352 192zm32 0c0 87.4-117 243-168.3 307.2c-12.3 15.3-35.1 15.3-47.4 0C117 435 0 279.4 0 192C0 86 86 0 192 0S384 86 384 192zm-240 0a48 48 0 1 0 96 0 48 48 0 1 0 -96 0zm48 80a80 80 0 1 1 0-160 80 80 0 1 1 0 160z"></path>
                                            </svg>
                                        </div>
                                    </div>
                                    <p class="text-gray-900 whitespace-nowrap text-body-sm">Houston, TX</p>
                                    <form method="post" action="/change-shopping-location" class="absolute min-w-[200px] p-4 hidden group-has-[:checked]:flex flex-col shadow-md bg-white z-[60] text-center rounded-xl overflow-hidden w-[85vw] xs:w-[80vw] max-w-[352px] bottom-16 mb-4 z-10 focus:outline-none" data-ax="select-shopping-location-form" data-discover="true">
                                        <h5 class="mb-2 text-label-lg text-gray-900 font-semibold">Shopping Locations</h5>
                                        <div class="mb-5">
                                            <p class="text-body-lg leading-6 text-gray-900">You are currently shopping in:</p>
                                            <p class="text-body-lg leading-6 text-burgundy-900">Houston, TX</p>
                                        </div>
                                        <div class="grid grid-cols-2 gap-4">
                                            <div class="flex flex-col items-center">
                                                <button aria-label="Las Vegas, NV" name="shoppingLocationId" value="1" type="submit" class="p-2.5 rounded-full bg-white">
                                                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 384 512" class="fill-burgundy-900" width="22" height="22">
                                                        <path d="M352 192c0-88.4-71.6-160-160-160S32 103.6 32 192c0 15.6 5.4 37 16.6 63.4c10.9 25.9 26.2 54 43.6 82.1c34.1 55.3 74.4 108.2 99.9 140c25.4-31.8 65.8-84.7 99.9-140c17.3-28.1 32.7-56.3 43.6-82.1C346.6 229 352 207.6 352 192zm32 0c0 87.4-117 243-168.3 307.2c-12.3 15.3-35.1 15.3-47.4 0C117 435 0 279.4 0 192C0 86 86 0 192 0S384 86 384 192zm-240 0a48 48 0 1 0 96 0 48 48 0 1 0 -96 0zm48 80a80 80 0 1 1 0-160 80 80 0 1 1 0 160z"></path>
                                                    </svg>
                                                </button>
                                                <p class="text-body-sm text-gray-900 whitespace-nowrap">Las Vegas, NV</p>
                                            </div>
                                            <div class="flex flex-col items-center">
                                                <button aria-label="Phoenix, AZ" name="shoppingLocationId" value="2" type="submit" class="p-2.5 rounded-full bg-white">
                                                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 384 512" class="fill-burgundy-900" width="22" height="22">
                                                        <path d="M352 192c0-88.4-71.6-160-160-160S32 103.6 32 192c0 15.6 5.4 37 16.6 63.4c10.9 25.9 26.2 54 43.6 82.1c34.1 55.3 74.4 108.2 99.9 140c25.4-31.8 65.8-84.7 99.9-140c17.3-28.1 32.7-56.3 43.6-82.1C346.6 229 352 207.6 352 192zm32 0c0 87.4-117 243-168.3 307.2c-12.3 15.3-35.1 15.3-47.4 0C117 435 0 279.4 0 192C0 86 86 0 192 0S384 86 384 192zm-240 0a48 48 0 1 0 96 0 48 48 0 1 0 -96 0zm48 80a80 80 0 1 1 0-160 80 80 0 1 1 0 160z"></path>
                                                    </svg>
                                                </button>
                                                <p class="text-body-sm text-gray-900 whitespace-nowrap">Phoenix, AZ</p>
                                            </div>
                                            <div class="flex flex-col items-center">
                                                <button aria-label="Houston, TX" name="shoppingLocationId" value="5" type="submit" class="p-2.5 rounded-full bg-burgundy-50">
                                                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 384 512" class="fill-burgundy-900" width="22" height="22">
                                                        <path d="M215.7 499.2C267 435 384 279.4 384 192C384 86 298 0 192 0S0 86 0 192c0 87.4 117 243 168.3 307.2c12.3 15.3 35.1 15.3 47.4 0zM192 128a64 64 0 1 1 0 128 64 64 0 1 1 0-128z"></path>
                                                    </svg>
                                                </button>
                                                <p class="text-body-sm text-gray-900 whitespace-nowrap">Houston, TX</p>
                                            </div>
                                            <div class="flex flex-col items-center">
                                                <button aria-label="Philadelphia, PA" name="shoppingLocationId" value="6" type="submit" class="p-2.5 rounded-full bg-white">
                                                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 384 512" class="fill-burgundy-900" width="22" height="22">
                                                        <path d="M352 192c0-88.4-71.6-160-160-160S32 103.6 32 192c0 15.6 5.4 37 16.6 63.4c10.9 25.9 26.2 54 43.6 82.1c34.1 55.3 74.4 108.2 99.9 140c25.4-31.8 65.8-84.7 99.9-140c17.3-28.1 32.7-56.3 43.6-82.1C346.6 229 352 207.6 352 192zm32 0c0 87.4-117 243-168.3 307.2c-12.3 15.3-35.1 15.3-47.4 0C117 435 0 279.4 0 192C0 86 86 0 192 0S384 86 384 192zm-240 0a48 48 0 1 0 96 0 48 48 0 1 0 -96 0zm48 80a80 80 0 1 1 0-160 80 80 0 1 1 0 160z"></path>
                                                    </svg>
                                                </button>
                                                <p class="text-body-sm text-gray-900 whitespace-nowrap">Philadelphia, PA</p>
                                            </div>
                                            <div class="flex flex-col items-center">
                                                <button aria-label="Denver, CO" name="shoppingLocationId" value="7" type="submit" class="p-2.5 rounded-full bg-white">
                                                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 384 512" class="fill-burgundy-900" width="22" height="22">
                                                        <path d="M352 192c0-88.4-71.6-160-160-160S32 103.6 32 192c0 15.6 5.4 37 16.6 63.4c10.9 25.9 26.2 54 43.6 82.1c34.1 55.3 74.4 108.2 99.9 140c25.4-31.8 65.8-84.7 99.9-140c17.3-28.1 32.7-56.3 43.6-82.1C346.6 229 352 207.6 352 192zm32 0c0 87.4-117 243-168.3 307.2c-12.3 15.3-35.1 15.3-47.4 0C117 435 0 279.4 0 192C0 86 86 0 192 0S384 86 384 192zm-240 0a48 48 0 1 0 96 0 48 48 0 1 0 -96 0zm48 80a80 80 0 1 1 0-160 80 80 0 1 1 0 160z"></path>
                                                    </svg>
                                                </button>
                                                <p class="text-body-sm text-gray-900 whitespace-nowrap">Denver, CO</p>
                                            </div>
                                            <div class="flex flex-col items-center">
                                                <button aria-label="Dallas, TX" name="shoppingLocationId" value="8" type="submit" class="p-2.5 rounded-full bg-white">
                                                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 384 512" class="fill-burgundy-900" width="22" height="22">
                                                        <path d="M352 192c0-88.4-71.6-160-160-160S32 103.6 32 192c0 15.6 5.4 37 16.6 63.4c10.9 25.9 26.2 54 43.6 82.1c34.1 55.3 74.4 108.2 99.9 140c25.4-31.8 65.8-84.7 99.9-140c17.3-28.1 32.7-56.3 43.6-82.1C346.6 229 352 207.6 352 192zm32 0c0 87.4-117 243-168.3 307.2c-12.3 15.3-35.1 15.3-47.4 0C117 435 0 279.4 0 192C0 86 86 0 192 0S384 86 384 192zm-240 0a48 48 0 1 0 96 0 48 48 0 1 0 -96 0zm48 80a80 80 0 1 1 0-160 80 80 0 1 1 0 160z"></path>
                                                    </svg>
                                                </button>
                                                <p class="text-body-sm text-gray-900 whitespace-nowrap">Dallas, TX</p>
                                            </div>
                                        </div>
                                        <input aria-label="Redirect" readonly="" name="referrer" hidden="" value="/p/Speediance-Gym-Monster-2-Smart-Home-Gym-Upgraded-AI-Powered-Home/50504133"/>
                                    </form>
                                </label>
                            </div>
                            <a data-ax="watchlist-link" data-discover="true" class="" href="/dashboard/auctions/watchlist">
                                <div class="flex flex-col items-center">
                                    <div class="px-2">
                                        <div class="p-2 rounded-full">
                                            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512" class="fill-burgundy-900" width="22" height="22">
                                                <path d="m244 130.6-12-13.5-4.2-4.7c-26-29.2-65.3-42.8-103.8-35.8-53.3 9.7-92 56.1-92 110.3v3.5c0 32.3 13.4 63.1 37.1 85.1L253 446.8c.8.7 1.9 1.2 3 1.2s2.2-.4 3-1.2l184-171.3c23.6-22 37-52.8 37-85.1v-3.5c0-54.2-38.7-100.6-92-110.3-38.5-7-77.8 6.6-103.8 35.8l-4.2 4.7-12 13.5c-3 3.4-7.4 5.4-12 5.4s-8.9-2-12-5.4zm34.9-57.1c32.1-25.1 73.8-35.8 114.8-28.4C462.2 57.6 512 117.3 512 186.9v3.5c0 36-13.1 70.6-36.6 97.5-3.4 3.8-6.9 7.5-10.7 11l-184 171.3c-.8.8-1.7 1.5-2.6 2.2-6.3 4.9-14.1 7.5-22.1 7.5-9.2 0-18-3.5-24.8-9.7L47.2 299c-3.8-3.5-7.3-7.2-10.7-11C13.1 261 0 226.4 0 190.4v-3.5C0 117.3 49.8 57.6 118.3 45.1c40.9-7.4 82.6 3.2 114.7 28.4 6.7 5.3 13 11.1 18.7 17.6l4.2 4.7 4.2-4.7c4.2-4.7 8.6-9.1 13.3-13.1l5.4-4.5z"></path>
                                            </svg>
                                        </div>
                                    </div>
                                    <p class="text-body-sm text-gray-900 whitespace-nowrap">Watchlist</p>
                                </div>
                            </a>
                            <a data-ax="outbid-link" data-discover="true" class="" href="/dashboard/auctions/outbid">
                                <div class="flex flex-col items-center">
                                    <div class="px-2">
                                        <div class="p-2 rounded-full">
                                            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512" width="22" height="22" class="fill-burgundy-900">
                                                <path d="M315.3 4.7c6.2 6.2 6.2 16.4 0 22.6L302.6 40 472 209.4l12.7-12.7c6.2-6.2 16.4-6.2 22.6 0s6.2 16.4 0 22.6l-24 24-96 96-24 24c-6.2 6.2-16.4 6.2-22.6 0s-6.2-16.4 0-22.6L353.4 328 184 158.6l-12.7 12.7c-6.2 6.2-16.4 6.2-22.6 0s-6.2-16.4 0-22.6l24-24 96-96 24-24c6.2-6.2 16.4-6.2 22.6 0zM206.6 136L376 305.4 449.4 232 280 62.6 206.6 136zM144 320L32 432l48 48L192 368l-48-48zm-22.6-22.6c12.5-12.5 32.8-12.5 45.3 0l12.7 12.7 49.8-49.8 22.6 22.6-49.8 49.8 12.7 12.7c12.5 12.5 12.5 32.8 0 45.3l-112 112c-12.5 12.5-32.8 12.5-45.3 0l-48-48c-12.5-12.5-12.5-32.8 0-45.3l112-112z"></path>
                                            </svg>
                                        </div>
                                    </div>
                                    <p class="text-body-sm text-gray-900 whitespace-nowrap">Outbid</p>
                                </div>
                            </a>
                            <a aria-label="Visit search page" data-ax="search-link" class="px-2 flex flex-col items-center" data-discover="true" href="/search">
                                <div class="p-2 rounded-full">
                                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512" class="fill-burgundy-900" width="22" height="22">
                                        <path d="M473.7 4.1C493.5 .2 512 15.3 512 35.5L512 168l-.2 0c.1 1.3 .2 2.7 .2 4c0 28.7-28.7 52-64 52s-64-23.3-64-52s28.7-52 64-52c11.7 0 22.6 2.5 32 7l0-91.4L352 61.1 352 200l-.2 0c.1 1.3 .2 2.7 .2 4c0 28.7-28.7 52-64 52s-64-23.3-64-52s28.7-52 64-52c11.7 0 22.6 2.5 32 7l0-97.8c0-15.3 10.8-28.4 25.7-31.4l128-25.6zM480 172c0-3.1-1.5-7.5-6.9-11.9c-5.5-4.5-14.3-8.1-25.1-8.1s-19.5 3.6-25.1 8.1c-5.5 4.4-6.9 8.8-6.9 11.9s1.5 7.5 6.9 11.9c5.5 4.5 14.3 8.1 25.1 8.1s19.5-3.6 25.1-8.1c5.5-4.4 6.9-8.8 6.9-11.9zM320 204c0-3.1-1.5-7.5-6.9-11.9c-5.5-4.5-14.3-8.1-25.1-8.1s-19.5 3.6-25.1 8.1c-5.5 4.4-6.9 8.8-6.9 11.9s1.5 7.5 6.9 11.9c5.5 4.5 14.3 8.1 25.1 8.1s19.5-3.6 25.1-8.1c5.5-4.4 6.9-8.8 6.9-11.9zM105.4 54.6l-6-6c-9-9-21.8-13.1-34.4-11c-19 3.2-33 19.6-33 38.9l0 2.9c0 11.9 4.9 23.2 13.6 31.4L128 187.7l82.4-76.9c8.7-8.1 13.6-19.5 13.6-31.4l0-2.9c0-19.3-13.9-35.8-33-38.9c-12.6-2.1-25.4 2-34.4 11l-6 6L128 77.3 105.4 54.6zM59.7 6C82.5 2.3 105.7 9.7 122 26c0 0 0 0 0 0l6 6 6-6C150.3 9.7 173.5 2.3 196.3 6C230.7 11.8 256 41.6 256 76.5l0 2.9c0 20.8-8.6 40.6-23.8 54.8l-90.4 84.3c-3.8 3.5-8.7 5.5-13.8 5.5s-10.1-2-13.8-5.5L23.8 134.2C8.6 120 0 100.2 0 79.5l0-2.9C0 41.6 25.3 11.8 59.7 6zM72 320l-24 0c-8.8 0-16 7.2-16 16l0 128c0 8.8 7.2 16 16 16l192 0c8.8 0 16-7.2 16-16l0-128c0-8.8-7.2-16-16-16l-24 0c-12.1 0-23.2-6.8-28.6-17.7L180.2 288l-72.4 0-7.2 14.3C95.2 313.2 84.1 320 72 320zm136.8-46.3L216 288l24 0c26.5 0 48 21.5 48 48l0 128c0 26.5-21.5 48-48 48L48 512c-26.5 0-48-21.5-48-48L0 336c0-26.5 21.5-48 48-48l24 0 7.2-14.3c5.4-10.8 16.5-17.7 28.6-17.7l72.4 0c12.1 0 23.2 6.8 28.6 17.7zM112 392a32 32 0 1 0 64 0 32 32 0 1 0 -64 0zm32 64a64 64 0 1 1 0-128 64 64 0 1 1 0 128zM475.3 283.3L390.6 368l89.4 0c6.5 0 12.3 3.9 14.8 9.9s1.1 12.9-3.5 17.4l-112 112c-6.2 6.2-16.4 6.2-22.6 0s-6.2-16.4 0-22.6L441.4 400 352 400c-6.5 0-12.3-3.9-14.8-9.9s-1.1-12.9 3.5-17.4l112-112c6.2-6.2 16.4-6.2 22.6 0s6.2 16.4 0 22.6z"></path>
                                    </svg>
                                </div>
                                <p class="text-body-sm text-gray-900 whitespace-nowrap">Browse</p>
                            </a>
                        </div>
                    </div>
                </div>
            </footer>
        </div>
        <script>
            ( (STORAGE_KEY, restoreKey) => {
                if (!window.history.state || !window.history.state.key) {
                    let key = Math.random().toString(32).slice(2);
                    window.history.replaceState({
                        key
                    }, "");
                }
                try {
                    let positions = JSON.parse(sessionStorage.getItem(STORAGE_KEY) || "{}");
                    let storedY = positions[restoreKey || window.history.state.key];
                    if (typeof storedY === "number") {
                        window.scrollTo(0, storedY);
                    }
                } catch (error) {
                    console.error(error);
                    sessionStorage.removeItem(STORAGE_KEY);
                }
            }
            )("positions", null)
        </script>
        <script id="autopilot-script" defer="">
            (function(o) {
                var b = 'https://briskeagle.io/anywhere/', t = 'eefdd74773a54cc1b43e558b34d33fe8f0c0c8555a25484aa42e180d26af0ca4', a = (window.AutopilotAnywhere = {
                    _runQueue: [],
                    run: function() {
                        this._runQueue.push(arguments);
                    }
                }), c = encodeURIComponent, s = 'SCRIPT', d = document, l = d.getElementsByTagName(s)[0], p = 't=' + c(d.title || '') + '&u=' + c(d.location.href || '') + '&r=' + c(d.referrer || ''), j = 'text/javascript', z, y;
                if (!window.Autopilot)
                    window.Autopilot = a;
                if (o.app)
                    p = 'devmode=true&' + p;
                z = function(src, asy) {
                    var e = d.createElement(s);
                    e.src = src;
                    e.type = j;
                    e.async = asy;
                    l.parentNode.insertBefore(e, l);
                }
                ;
                y = function() {
                    z(b + t + '?' + p, true);
                }
                ;
                if (window.attachEvent) {
                    window.attachEvent('onload', y);
                } else {
                    window.addEventListener('load', y, false);
                }
            }
            )({});
        </script>
        <script type="text/javascript" src="https://static.klaviyo.com/onsite/js/UDQmHy/klaviyo.js"></script>
        <link rel="modulepreload" href="/build/manifest-3115FC54.js"/>
        <link rel="modulepreload" href="/build/entry.client-4Z43EWQZ.js"/>
        <link rel="modulepreload" href="/build/_shared/chunk-Q5DUUX64.js"/>
        <link rel="modulepreload" href="/build/_shared/chunk-QWEG3L7L.js"/>
        <link rel="modulepreload" href="/build/_shared/chunk-YQJTGBQO.js"/>
        <link rel="modulepreload" href="/build/_shared/chunk-HDOWR2FO.js"/>
        <link rel="modulepreload" href="/build/_shared/chunk-NG6D2T4P.js"/>
        <link rel="modulepreload" href="/build/_shared/chunk-QFHFTSKA.js"/>
        <link rel="modulepreload" href="/build/_shared/chunk-WGMZMA5L.js"/>
        <link rel="modulepreload" href="/build/_shared/chunk-ADMCF34Z.js"/>
        <link rel="modulepreload" href="/build/_shared/chunk-L7XORQ6J.js"/>
        <link rel="modulepreload" href="/build/_shared/chunk-4DAEZZ4P.js"/>
        <link rel="modulepreload" href="/build/_shared/chunk-OGUXWO6D.js"/>
        <link rel="modulepreload" href="/build/_shared/chunk-MCDF3TRA.js"/>
        <link rel="modulepreload" href="/build/_shared/chunk-UT56IP6I.js"/>
        <link rel="modulepreload" href="/build/_shared/chunk-PRVLOSAG.js"/>
        <link rel="modulepreload" href="/build/_shared/chunk-NE5URION.js"/>
        <link rel="modulepreload" href="/build/_shared/chunk-PD7F2IWV.js"/>
        <link rel="modulepreload" href="/build/_shared/chunk-D7EHPM25.js"/>
        <link rel="modulepreload" href="/build/_shared/chunk-5F7NJTCV.js"/>
        <link rel="modulepreload" href="/build/_shared/chunk-IPIDSZAP.js"/>
        <link rel="modulepreload" href="/build/_shared/chunk-J2M76OXU.js"/>
        <link rel="modulepreload" href="/build/_shared/chunk-4N7QDAWX.js"/>
        <link rel="modulepreload" href="/build/_shared/chunk-FW3HZK4D.js"/>
        <link rel="modulepreload" href="/build/_shared/chunk-7JKJQLZM.js"/>
        <link rel="modulepreload" href="/build/_shared/chunk-UQLN7TVO.js"/>
        <link rel="modulepreload" href="/build/_shared/chunk-MHGSSQAG.js"/>
        <link rel="modulepreload" href="/build/_shared/chunk-NDMDNTL6.js"/>
        <link rel="modulepreload" href="/build/_shared/chunk-CL36L7R2.js"/>
        <link rel="modulepreload" href="/build/_shared/chunk-MEM5V266.js"/>
        <link rel="modulepreload" href="/build/_shared/chunk-GCKR57CW.js"/>
        <link rel="modulepreload" href="/build/_shared/chunk-7Y722TRA.js"/>
        <link rel="modulepreload" href="/build/_shared/chunk-KTR6TZGX.js"/>
        <link rel="modulepreload" href="/build/_shared/chunk-4P26GDXR.js"/>
        <link rel="modulepreload" href="/build/_shared/chunk-ZXWUME2Z.js"/>
        <link rel="modulepreload" href="/build/_shared/chunk-KKDCTBB5.js"/>
        <link rel="modulepreload" href="/build/_shared/chunk-O6WVYGTO.js"/>
        <link rel="modulepreload" href="/build/_shared/chunk-YMODZ6T3.js"/>
        <link rel="modulepreload" href="/build/_shared/chunk-4RAF75LQ.js"/>
        <link rel="modulepreload" href="/build/_shared/chunk-BSPBVDV4.js"/>
        <link rel="modulepreload" href="/build/_shared/chunk-MLTCNO3J.js"/>
        <link rel="modulepreload" href="/build/_shared/chunk-CGJPGF4U.js"/>
        <link rel="modulepreload" href="/build/_shared/chunk-HSSTFHR3.js"/>
        <link rel="modulepreload" href="/build/_shared/chunk-XB7HV5KB.js"/>
        <link rel="modulepreload" href="/build/_shared/chunk-PVID3DNZ.js"/>
        <link rel="modulepreload" href="/build/_shared/chunk-VHSGOCGQ.js"/>
        <link rel="modulepreload" href="/build/_shared/chunk-QEQTEAIA.js"/>
        <link rel="modulepreload" href="/build/_shared/chunk-RMDKL2IT.js"/>
        <link rel="modulepreload" href="/build/_shared/chunk-VZQVWFLO.js"/>
        <link rel="modulepreload" href="/build/_shared/chunk-7QLVLIBI.js"/>
        <link rel="modulepreload" href="/build/root-OVVLGCFO.js"/>
        <link rel="modulepreload" href="/build/_shared/chunk-TGQID5IV.js"/>
        <link rel="modulepreload" href="/build/_shared/chunk-3OONPNXY.js"/>
        <link rel="modulepreload" href="/build/_shared/chunk-JUSZJO4J.js"/>
        <link rel="modulepreload" href="/build/_shared/chunk-3NCF6JFS.js"/>
        <link rel="modulepreload" href="/build/_shared/chunk-7Z5Y6QSI.js"/>
        <link rel="modulepreload" href="/build/_shared/chunk-7U2UINOS.js"/>
        <link rel="modulepreload" href="/build/_shared/chunk-MI7C2UOB.js"/>
        <link rel="modulepreload" href="/build/_shared/chunk-22IEBXEP.js"/>
        <link rel="modulepreload" href="/build/_shared/chunk-JJJURPFD.js"/>
        <link rel="modulepreload" href="/build/_shared/chunk-ZFPYQIC5.js"/>
        <link rel="modulepreload" href="/build/_shared/chunk-TCX2G7A2.js"/>
        <link rel="modulepreload" href="/build/_shared/chunk-AJOKRXIQ.js"/>
        <link rel="modulepreload" href="/build/_shared/chunk-ZHFXWFP4.js"/>
        <link rel="modulepreload" href="/build/_shared/chunk-LZOKC3DK.js"/>
        <link rel="modulepreload" href="/build/_shared/chunk-GFSZCIK6.js"/>
        <link rel="modulepreload" href="/build/_shared/chunk-4KK2JSJJ.js"/>
        <link rel="modulepreload" href="/build/_shared/chunk-ZG7INWSI.js"/>
        <link rel="modulepreload" href="/build/_shared/chunk-VZSLTQOM.js"/>
        <link rel="modulepreload" href="/build/_shared/chunk-PPDU6IIR.js"/>
        <link rel="modulepreload" href="/build/_shared/chunk-SS3FZEOS.js"/>
        <link rel="modulepreload" href="/build/_shared/chunk-FYTPAK54.js"/>
        <link rel="modulepreload" href="/build/_shared/chunk-DIIYNTPK.js"/>
        <link rel="modulepreload" href="/build/_shared/chunk-GY2YXAJZ.js"/>
        <link rel="modulepreload" href="/build/_shared/chunk-Y2GYYJR6.js"/>
        <link rel="modulepreload" href="/build/_shared/chunk-J27WQDOM.js"/>
        <link rel="modulepreload" href="/build/_shared/chunk-5GYDZYO3.js"/>
        <link rel="modulepreload" href="/build/_shared/chunk-EME7ECDY.js"/>
        <link rel="modulepreload" href="/build/_shared/chunk-OOEQGQZU.js"/>
        <link rel="modulepreload" href="/build/_shared/chunk-CQDBKBEG.js"/>
        <link rel="modulepreload" href="/build/_shared/chunk-5DU4ZSE2.js"/>
        <link rel="modulepreload" href="/build/routes/p.$title.$productId-WFGPKXUD.js"/>
        <link rel="modulepreload" href="/build/_shared/chunk-DSTW5Q5M.js"/>
        <link rel="modulepreload" href="/build/_shared/chunk-32POK22I.js"/>
        <link rel="modulepreload" href="/build/_shared/chunk-UT7JQAW3.js"/>
        <link rel="modulepreload" href="/build/_shared/chunk-FROOOC5N.js"/>
        <link rel="modulepreload" href="/build/_shared/chunk-XE5KWFUF.js"/>
        <link rel="modulepreload" href="/build/_shared/chunk-NQHS57VO.js"/>
        <link rel="modulepreload" href="/build/_shared/chunk-KRP5Q44G.js"/>
        <link rel="modulepreload" href="/build/_shared/chunk-WJYPVGIO.js"/>
        <link rel="modulepreload" href="/build/_shared/chunk-P354JOID.js"/>
        <link rel="modulepreload" href="/build/_shared/chunk-PGJITTOB.js"/>
        <link rel="modulepreload" href="/build/_shared/chunk-ET7KOIX4.js"/>
        <link rel="modulepreload" href="/build/_shared/chunk-UNB4UH56.js"/>
        <link rel="modulepreload" href="/build/_shared/chunk-FZ43YFCJ.js"/>
        <link rel="modulepreload" href="/build/_shared/chunk-XORTQHQN.js"/>
        <link rel="modulepreload" href="/build/_shared/chunk-TOESROYF.js"/>
        <link rel="modulepreload" href="/build/_shared/chunk-26VCOM4I.js"/>
        <link rel="modulepreload" href="/build/_shared/chunk-TDB32P2Y.js"/>
        <link rel="modulepreload" href="/build/_shared/chunk-ZSSJYMBQ.js"/>
        <link rel="modulepreload" href="/build/_shared/chunk-WXRI7JWP.js"/>
        <link rel="modulepreload" href="/build/_shared/chunk-Y4BIKBNZ.js"/>
        <link rel="modulepreload" href="/build/_shared/chunk-DQVEYPDT.js"/>
        <link rel="modulepreload" href="/build/_shared/chunk-55YAUHOK.js"/>
        <link rel="modulepreload" href="/build/_shared/chunk-CIK5E3JR.js"/>
        <link rel="modulepreload" href="/build/routes/p.$title.$productId._index-SZVMAAC5.js"/>
        <script>
            window.__remixContext = {
                "url": "/p/Speediance-Gym-Monster-2-Smart-Home-Gym-Upgraded-AI-Powered-Home/50504133",
                "future": {
                    "v3_fetcherPersist": false,
                    "v3_relativeSplatPath": false,
                    "v3_throwAbortReason": false,
                    "unstable_singleFetch": false,
                    "unstable_lazyRouteDiscovery": false
                },
                "state": {
                    "loaderData": {
                        "root": {
                            "userData": null,
                            "env": {
                                "APP_PUBLIC_ALGOLIA_API_KEY": "d22f83c614aa8eda28fa9eadda0d07b9",
                                "APP_PUBLIC_ALGOLIA_ID": "GL1QVP8R29",
                                "APP_PUBLIC_ALGOLIA_INDEX": "nellisauction-prd",
                                "APP_PUBLIC_ALGOLIA_QUERY_SUGGESTIONS_DEFAULT_INDEX": "nellisauction-prd_query_suggestions_default",
                                "APP_PUBLIC_AUTO_PILOT_CLIENT_TOKEN": "eefdd74773a54cc1b43e558b34d33fe8f0c0c8555a25484aa42e180d26af0ca4",
                                "APP_PUBLIC_BUYER_FRONTEND_URL": "https://www.nellisauction.com",
                                "APP_PUBLIC_FACEBOOK_PIXEL_ID": "",
                                "APP_PUBLIC_GOOGLE_ANALYTICS_APP_ID": "UA-39323446-2",
                                "APP_PUBLIC_GOOGLE_API_KEY": "AIzaSyB61qnxZvOGUcvmZNNDIyEh-DcwgN5W930",
                                "APP_PUBLIC_GOOGLE_MAPS_API_KEY": "AIzaSyB61qnxZvOGUcvmZNNDIyEh-DcwgN5W930",
                                "APP_PUBLIC_GOOGLE_SITE_VERIFICATION": "QsidqRM-HnmZMhcfra_uJBglmmZ0O-wpLJ87z2OfiBY",
                                "APP_PUBLIC_GOOGLE_TAG_MANAGER_ID": "GTM-WB9L6N3",
                                "APP_PUBLIC_KLAVIYO_PUBLIC_API_KEY": "UDQmHy",
                                "APP_PUBLIC_KOUNT_COLLECTOR_HOSTNAME": "ssl.kaptcha.com",
                                "APP_PUBLIC_KOUNT_MERCHANT_ID": "100066",
                                "APP_PUBLIC_NELLIS_API_URL": "https://cargo.prd.nellis.run/api",
                                "APP_PUBLIC_SENTRY_DSN": "https://b61eb32f6d314323a9758b0f9c2dc18f@o103832.ingest.sentry.io/5837505",
                                "APP_PUBLIC_SSE_URL": "https://sse.nellisauction.com",
                                "APP_PUBLIC_HEAP_APP_ID": "",
                                "APP_PUBLIC_SENTRY_ENVIRONMENT": "",
                                "APP_PUBLIC_BUILD_INFO": "{\"GIT_COMMIT_REF\":\"prd\",\"GIT_COMMIT_SHA\":\"dc7ce6e939bc25ad4cef6aef7c73738ba07692b7\",\"GIT_COMMIT_TIMESTAMP\":\"2025-04-09T20:00:49Z\",\"GIT_TAG\":\"release/v2025.1.3\",\"VERSION\":\"v2025.1.3\"}",
                                "APP_PUBLIC_DOMAIN": ""
                            },
                            "snackBarAlerts": [],
                            "currentShoppingLocation": {
                                "id": 5,
                                "name": "Houston, TX",
                                "locationPhoto": []
                            },
                            "featureGroup": "b",
                            "shoppingLocations": [{
                                "id": 1,
                                "name": "Las Vegas, NV",
                                "code": "las",
                                "enabled": true,
                                "latitude": 36.16994,
                                "longitude": -115.1398,
                                "createdAt": {
                                    "__type": "Date",
                                    "value": "1970-01-01T00:00:00.000Z"
                                },
                                "updatedAt": {
                                    "__type": "Date",
                                    "value": "2025-03-06T21:46:55.138Z"
                                },
                                "locationPhoto": [{
                                    "id": 65,
                                    "locationId": null,
                                    "photoId": 65,
                                    "shoppingLocationId": 1,
                                    "photo": {
                                        "id": 65,
                                        "format": "jpg",
                                        "name": "nevada_900",
                                        "properties": {},
                                        "url": "https://storage.googleapis.com/na-location-images-prd/nevada_900.jpg"
                                    }
                                }]
                            }, {
                                "id": 2,
                                "name": "Phoenix, AZ",
                                "code": "phx",
                                "enabled": true,
                                "latitude": 33.44838,
                                "longitude": -112.074,
                                "createdAt": {
                                    "__type": "Date",
                                    "value": "1970-01-01T00:00:00.000Z"
                                },
                                "updatedAt": {
                                    "__type": "Date",
                                    "value": "2025-03-06T21:46:55.144Z"
                                },
                                "locationPhoto": [{
                                    "id": 64,
                                    "locationId": null,
                                    "photoId": 64,
                                    "shoppingLocationId": 2,
                                    "photo": {
                                        "id": 64,
                                        "format": "jpg",
                                        "name": "arizona_900",
                                        "properties": {},
                                        "url": "https://storage.googleapis.com/na-location-images-prd/arizona_900.jpg"
                                    }
                                }]
                            }, {
                                "id": 5,
                                "name": "Houston, TX",
                                "code": "hou",
                                "enabled": true,
                                "latitude": 29.76043,
                                "longitude": -95.3698,
                                "createdAt": {
                                    "__type": "Date",
                                    "value": "2023-04-20T15:26:53.000Z"
                                },
                                "updatedAt": {
                                    "__type": "Date",
                                    "value": "2025-03-06T21:46:55.130Z"
                                },
                                "locationPhoto": [{
                                    "id": 66,
                                    "locationId": null,
                                    "photoId": 66,
                                    "shoppingLocationId": 5,
                                    "photo": {
                                        "id": 66,
                                        "format": "jpg",
                                        "name": "texas_900",
                                        "properties": {},
                                        "url": "https://storage.googleapis.com/na-location-images-prd/texas_900.jpg"
                                    }
                                }]
                            }, {
                                "id": 6,
                                "name": "Philadelphia, PA",
                                "code": "phi",
                                "enabled": true,
                                "latitude": 39.95258,
                                "longitude": -75.16522,
                                "createdAt": {
                                    "__type": "Date",
                                    "value": "2024-03-19T06:47:29.000Z"
                                },
                                "updatedAt": {
                                    "__type": "Date",
                                    "value": "2025-03-06T21:46:55.150Z"
                                },
                                "locationPhoto": [{
                                    "id": 67,
                                    "locationId": null,
                                    "photoId": 67,
                                    "shoppingLocationId": 6,
                                    "photo": {
                                        "id": 67,
                                        "format": "webp",
                                        "name": "pennsylvania_900",
                                        "properties": {},
                                        "url": "https://storage.googleapis.com/na-location-images-prd/pennsylvania_900.webp"
                                    }
                                }]
                            }, {
                                "id": 7,
                                "name": "Denver, CO",
                                "code": "den",
                                "enabled": true,
                                "latitude": 39.7392,
                                "longitude": -104.9903,
                                "createdAt": {
                                    "__type": "Date",
                                    "value": "2024-12-16T13:36:48.000Z"
                                },
                                "updatedAt": {
                                    "__type": "Date",
                                    "value": "2025-03-06T21:46:55.124Z"
                                },
                                "locationPhoto": [{
                                    "id": 68,
                                    "locationId": null,
                                    "photoId": 61,
                                    "shoppingLocationId": 7,
                                    "photo": {
                                        "id": 61,
                                        "format": "webp",
                                        "name": "denver_900",
                                        "properties": {},
                                        "url": "https://storage.googleapis.com/na-location-images-prd/denver_900.webp"
                                    }
                                }, {
                                    "id": 69,
                                    "locationId": null,
                                    "photoId": 62,
                                    "shoppingLocationId": 7,
                                    "photo": {
                                        "id": 62,
                                        "format": "jpg",
                                        "name": "denver_900",
                                        "properties": {},
                                        "url": "https://storage.googleapis.com/na-location-images-prd/denver_900.jpg"
                                    }
                                }, {
                                    "id": 70,
                                    "locationId": null,
                                    "photoId": 63,
                                    "shoppingLocationId": 7,
                                    "photo": {
                                        "id": 63,
                                        "format": "avif",
                                        "name": "denver_900",
                                        "properties": {},
                                        "url": "https://storage.googleapis.com/na-location-images-prd/denver_900.avif"
                                    }
                                }]
                            }, {
                                "id": 8,
                                "name": "Dallas, TX",
                                "code": "dal",
                                "enabled": true,
                                "latitude": 32.77917,
                                "longitude": -96.80889,
                                "createdAt": {
                                    "__type": "Date",
                                    "value": "2025-03-25T21:32:41.566Z"
                                },
                                "updatedAt": {
                                    "__type": "Date",
                                    "value": "2025-04-01T16:52:01.878Z"
                                },
                                "locationPhoto": [{
                                    "id": 71,
                                    "locationId": null,
                                    "photoId": 68,
                                    "shoppingLocationId": 8,
                                    "photo": {
                                        "id": 68,
                                        "format": "jpg",
                                        "name": "dallas_900",
                                        "properties": {},
                                        "url": "https://storage.googleapis.com/na-location-images-prd/dallas_900.jpg"
                                    }
                                }]
                            }],
                            "querySuggestionsIndexName": "nellisauction-prd_query_suggestions_default-strategy-a",
                            "sentryTrace": "d70e91064eaa4fbcbd71c22f04404bc7-83ff44808e8e052c-1",
                            "sentryBaggage": "sentry-environment=production,sentry-public_key=b61eb32f6d314323a9758b0f9c2dc18f,sentry-trace_id=d70e91064eaa4fbcbd71c22f04404bc7,sentry-sample_rate=1,sentry-transaction=routes%2Fp.%24title.%24productId._index,sentry-sampled=true",
                            "remixVersion": 2
                        },
                        "routes/p.$title.$productId": {
                            "productId": 50504133
                        },
                        "routes/p.$title.$productId._index": {
                            "product": {
                                "id": 50504133,
                                "grade": {
                                    "assemblyType": {
                                        "id": 1,
                                        "description": "Yes"
                                    },
                                    "missingPartsType": {
                                        "id": 6,
                                        "description": "No"
                                    },
                                    "functionalType": {
                                        "id": 1,
                                        "description": "Yes"
                                    },
                                    "conditionType": {
                                        "id": 5,
                                        "description": "New"
                                    },
                                    "damageType": {
                                        "id": 7,
                                        "description": "None"
                                    },
                                    "packageType": {
                                        "id": 5,
                                        "description": "Yes"
                                    },
                                    "rating": 5
                                },
                                "title": "Speediance Gym Monster 2 Smart Home Gym, Upgraded AI-Powered Home Workout Machine, Multi-Functional Smith Machine, Full Body Strength Training Fitness Equipment, All-in-One Workout Station",
                                "inventoryNumber": "1037519722",
                                "photos": [{
                                    "url": "https://images-na.ssl-images-amazon.com/images/I/61s+dEzQFTL.jpg",
                                    "name": "https://images-na.ssl-images-amazon.com/images/I/61s+dEzQFTL.jpg",
                                    "fullPath": "https://images-na.ssl-images-amazon.com/images/I/61s+dEzQFTL.jpg"
                                }, {
                                    "url": "https://firebasestorage.googleapis.com/v0/b/nellishr-cbba0.appspot.com/o/processing-photos%2F1037519722%2FNNLastRxUi6UDeywWGHH0.jpeg?alt=media\u0026token=ab59f573-17a4-4248-b08a-a06f3c26fdb2",
                                    "name": "NNLastRxUi6UDeywWGHH0.jpeg",
                                    "fullPath": "processing-photos/1037519722/NNLastRxUi6UDeywWGHH0.jpeg"
                                }, {
                                    "url": "https://firebasestorage.googleapis.com/v0/b/nellishr-cbba0.appspot.com/o/processing-photos%2F1037519722%2F5-zKtjO1cy0wldRFiPnR5.jpeg?alt=media\u0026token=8f1dd1f6-8cad-4766-b2ef-25870853df79",
                                    "name": "5-zKtjO1cy0wldRFiPnR5.jpeg",
                                    "fullPath": "processing-photos/1037519722/5-zKtjO1cy0wldRFiPnR5.jpeg"
                                }],
                                "retailPrice": 4200,
                                "notes": "",
                                "bidCount": 22,
                                "currentPrice": 503,
                                "openTime": {
                                    "__type": "Date",
                                    "value": "2025-04-28T02:01:13.415Z"
                                },
                                "closeTime": {
                                    "__type": "Date",
                                    "value": "2025-04-29T01:26:00.000Z"
                                },
                                "isClosed": false,
                                "marketStatus": "open",
                                "location": {
                                    "id": 5,
                                    "name": "Katy",
                                    "offsite": false,
                                    "timezone": "America/Chicago",
                                    "address": "3615 W Grand Pkwy N",
                                    "city": "Katy",
                                    "state": "TX",
                                    "zipCode": 77449
                                },
                                "originType": "revalidate",
                                "extensionInterval": 30,
                                "initialCloseTime": {
                                    "__type": "Date",
                                    "value": "2025-04-29T01:26:00.000Z"
                                },
                                "projectExtended": false,
                                "taxonomyLevel1": "Outdoors \u0026 Sports",
                                "taxonomyLevel2": "Outdoor Recreation"
                            },
                            "bidHistory": [{
                                "time": {
                                    "__type": "Date",
                                    "value": "2025-04-28T19:30:12.655Z"
                                },
                                "name": "Bidder #12",
                                "amount": "$503",
                                "type": "Winning",
                                "highlightOutbid": false
                            }, {
                                "time": {
                                    "__type": "Date",
                                    "value": "2025-04-28T19:25:13.171Z"
                                },
                                "name": "Bidder #11",
                                "amount": "$502",
                                "type": "Outbid",
                                "highlightOutbid": false
                            }, {
                                "time": {
                                    "__type": "Date",
                                    "value": "2025-04-28T17:32:06.336Z"
                                },
                                "name": "Bidder #10",
                                "amount": "$501",
                                "type": "Outbid",
                                "highlightOutbid": false
                            }, {
                                "time": {
                                    "__type": "Date",
                                    "value": "2025-04-28T13:41:10.666Z"
                                },
                                "name": "Bidder #7",
                                "amount": "$500",
                                "type": "Outbid",
                                "highlightOutbid": false
                            }, {
                                "time": {
                                    "__type": "Date",
                                    "value": "2025-04-28T17:32:03.439Z"
                                },
                                "name": "Bidder #10",
                                "amount": "$451",
                                "type": "Outbid",
                                "highlightOutbid": false
                            }, {
                                "time": {
                                    "__type": "Date",
                                    "value": "2025-04-28T17:30:36.326Z"
                                },
                                "name": "Bidder #10",
                                "amount": "$401",
                                "type": "Outbid",
                                "highlightOutbid": false
                            }, {
                                "time": {
                                    "__type": "Date",
                                    "value": "2025-04-28T17:30:31.714Z"
                                },
                                "name": "Bidder #10",
                                "amount": "$371",
                                "type": "Outbid",
                                "highlightOutbid": false
                            }, {
                                "time": {
                                    "__type": "Date",
                                    "value": "2025-04-28T14:14:52.944Z"
                                },
                                "name": "Bidder #9",
                                "amount": "$350",
                                "type": "Outbid",
                                "highlightOutbid": false
                            }, {
                                "time": {
                                    "__type": "Date",
                                    "value": "2025-04-28T14:14:48.635Z"
                                },
                                "name": "Bidder #9",
                                "amount": "$330",
                                "type": "Outbid",
                                "highlightOutbid": false
                            }, {
                                "time": {
                                    "__type": "Date",
                                    "value": "2025-04-28T14:14:41.012Z"
                                },
                                "name": "Bidder #9",
                                "amount": "$320",
                                "type": "Outbid",
                                "highlightOutbid": false
                            }, {
                                "time": {
                                    "__type": "Date",
                                    "value": "2025-04-28T14:08:14.774Z"
                                },
                                "name": "Bidder #8",
                                "amount": "$305",
                                "type": "Outbid",
                                "highlightOutbid": false
                            }, {
                                "time": {
                                    "__type": "Date",
                                    "value": "2025-04-28T05:17:46.988Z"
                                },
                                "name": "Bidder #5",
                                "amount": "$300",
                                "type": "Outbid",
                                "highlightOutbid": false
                            }, {
                                "time": {
                                    "__type": "Date",
                                    "value": "2025-04-28T13:41:01.463Z"
                                },
                                "name": "Bidder #7",
                                "amount": "$300",
                                "type": "Outbid",
                                "highlightOutbid": false
                            }, {
                                "time": {
                                    "__type": "Date",
                                    "value": "2025-04-28T13:40:56.135Z"
                                },
                                "name": "Bidder #7",
                                "amount": "$250",
                                "type": "Outbid",
                                "highlightOutbid": false
                            }, {
                                "time": {
                                    "__type": "Date",
                                    "value": "2025-04-28T06:34:13.411Z"
                                },
                                "name": "Bidder #6",
                                "amount": "$202",
                                "type": "Outbid",
                                "highlightOutbid": false
                            }, {
                                "time": {
                                    "__type": "Date",
                                    "value": "2025-04-28T02:57:24.770Z"
                                },
                                "name": "Bidder #4",
                                "amount": "$200",
                                "type": "Outbid",
                                "highlightOutbid": false
                            }, {
                                "time": {
                                    "__type": "Date",
                                    "value": "2025-04-28T02:09:57.142Z"
                                },
                                "name": "Bidder #2",
                                "amount": "$150",
                                "type": "Outbid",
                                "highlightOutbid": false
                            }, {
                                "time": {
                                    "__type": "Date",
                                    "value": "2025-04-28T02:57:20.746Z"
                                },
                                "name": "Bidder #4",
                                "amount": "$125",
                                "type": "Outbid",
                                "highlightOutbid": false
                            }, {
                                "time": {
                                    "__type": "Date",
                                    "value": "2025-04-28T02:45:19.484Z"
                                },
                                "name": "Bidder #4",
                                "amount": "$110",
                                "type": "Outbid",
                                "highlightOutbid": false
                            }, {
                                "time": {
                                    "__type": "Date",
                                    "value": "2025-04-28T02:18:19.338Z"
                                },
                                "name": "Bidder #3",
                                "amount": "$105",
                                "type": "Outbid",
                                "highlightOutbid": false
                            }, {
                                "time": {
                                    "__type": "Date",
                                    "value": "2025-04-28T02:04:03.621Z"
                                },
                                "name": "Bidder #1",
                                "amount": "$103",
                                "type": "Outbid",
                                "highlightOutbid": false
                            }, {
                                "time": {
                                    "__type": "Date",
                                    "value": "2025-04-28T02:09:51.932Z"
                                },
                                "name": "Bidder #2",
                                "amount": "$50",
                                "type": "Outbid",
                                "highlightOutbid": false
                            }],
                            "shoppingLocation": {
                                "id": 5,
                                "name": "Houston, TX",
                                "locationPhoto": []
                            },
                            "noReferrer": true
                        }
                    },
                    "actionData": null,
                    "errors": null
                }
            };
        </script>
        <script type="module" async="">
            import "/build/manifest-3115FC54.js";
            import*as route0 from "/build/root-OVVLGCFO.js";
            import*as route1 from "/build/routes/p.$title.$productId-WFGPKXUD.js";
            import*as route2 from "/build/routes/p.$title.$productId._index-SZVMAAC5.js";

            window.__remixRouteModules = {
                "root": route0,
                "routes/p.$title.$productId": route1,
                "routes/p.$title.$productId._index": route2
            };

            import("/build/entry.client-4Z43EWQZ.js");
        </script>
    </body>
</html>

```

Specifically, from that, we will find that the price was $503. If it closed, it'd used the text `Won for` like this for a price of $141:

```html
<div class="md:col-start-2 md:row-start-2 xl:col-start-3 xl:row-start-1 xl:sticky xl:row-span-4">
                            <div class="z-10 bg-white shadow-lg my-4 grid md:my-0 xl:sticky xl:top-36 md:rounded-itemCard md:gap-2.5 bid-message-slide-up">
                                <div class="px-4 py-2 md:py-4 flex items-center justify-center gap-4 md:rounded-t-itemCard border-x border-t md:border-b">
                                    <div class="h-full py-2 flex-1 flex flex-col items-center justify-center rounded-[0.625rem] bg-neutral-200" data-ax="item-card-time-countdown-container">
                                        <p class="relative text-body-sm font-bold uppercase text-gray-900 w-full text-center">
                                            <strong class="">Ended</strong>
                                        </p>
                                        <p class="text-gray-900 font-semibold line-clamp-1 text-label-sm xxs:text-title-xs xs:text-label-md sm:text-title-xs md:text-title-sm lg:text-title-md xl:text-title-sm xxl:text-title-xs">21 hours</p>
                                    </div>
                                    <div class="h-full py-2 flex-1 flex flex-col items-center justify-center rounded-[0.625rem] bg-neutral-200 ">
                                        <p class="relative text-body-sm font-bold uppercase text-gray-900 w-full text-center">
                                            <strong class="">Won For</strong>
                                        </p>
                                        <p class="text-gray-900 font-semibold line-clamp-1 text-label-sm xxs:text-title-xs xs:text-label-md sm:text-title-xs md:text-title-sm lg:text-title-md xl:text-title-sm xxl:text-title-xs">$141</p>
                                    </div>
                                </div>
                                <div class="mb-4 mx-4">
                                    <a class="relative block w-fit text-body-lg font-semibold rounded-[0.625rem] w-full text-white fill-white uppercase bg-gradient-to-r from-primary to-[#93291E]
    hover:from-sincity-red-800 hover:to-[#7D0000]
    focus:to-[#7D0000] focus:outline focus:outline-[3px] focus:outline-[#F397A2]
    disabled:from-gray-900 disabled:to-neutral-600 py-2 px-4 text-body-lg font-semibold" data-discover="true" href="/search">
                                        <span class="flex items-center justify-center opacity-100 undefined">Search Active Auctions</span>
                                    </a>
                                </div>
                            </div>
                        </div>
```

Thus, implement a method to fetch this HTML from the data you have about a listing (i.e. name and Id) and return either the current or final price with a current state. Remember, unfortunately for this method, there is no using the query parameter `_data` to get a JSON serialized version. Now that we have a way of just scanning an auction for only closing price, we do not need to utilize the server sent events. Keep the code in Core, but delete the Hangfire usage and following up on that. Instead, just query every 30 minutes for items via search, get their Ids, and track the listing. Once every day, we can scan all auctions that closed in the last 24 hours and get the final price.

Second, I need us to change what we're storing in the database. We want to key listings of their Id - not a value generated on add. We can simply align the Id of the product and the Id in the database. So for every auction we track, we track a single record with the current/end price as well as the current state of the auction. In addition, we need to track the inventory id of those listings as an indexed field. So perhaps have a second table of inventory with the name/description of an item with that inventory as a foreign key in the first. Long story short, the objective is to make it so that I can track, for any given inventory id, what listings have occurred and what the closing price was.

Third, I'd like you to create a test project focusing on the external integration i.e. the `NellisScanner.Core`. I don't want to use mocking, I just want to test against the live site for each. These are the rough tests I want:

1. Test that fetching the root page returns 100 or more results.
2. Test that fetching the product page i.e. the `/p/` of a given Id returns the price and its state (whether it's ongoing or if it closed).

These tests are related as to, find an active listing, you must first fetch the search and grab one of the products.

Finally, I want to delete everything about Bootstrap and switch everything to Tailwind. Import necessary libraries and tweak all existing CSS in the web project to make this switch.

### Addon Prompts

1. We got interrupted, can you resume updating all components to use Tailwind CSS classes instead of Bootstrap?
2. Can you fix the current build errors relating to the DbContext?
3. Can you generate the next migration for the web portion of this?

### Results

This time, it's a little easier to see that it does seem mostly reasonable. It's by no means perfect, and it seems aggressive at getting rid of things that weren't hurting anything. Maybe that's because there is a difference in understanding whether something **shall** or something **should**. I think to humans, should represents a minimum. It should tell you the right answer, but that does not prescribe that it may not also tell you the right time.

## 03 - Refine API

In the core scanner code, `page={page}` will not work. The website uses this URL encoded syntax `_p1=s%3A120%2Cn%3A0` which is `_p1=s:120,n:0` where s is the size of a single page and n is the page number. You should refactor the method `GetElectronicsHighToLowAsync` to support parameters for the core filter instead of `Electronics`, the size of a page in number of returned products, and the page number.

For the filter, allow the user to select one of these using best practices (e.g. an `enum` with descriptions, `const string` in a separate class, whatever makes you feel good):

* Electronics
* Home+%26+Household+Essentials
* Home+Improvement
* Smart+Home
* Office+%26+School+Supplies
* Automotive

If a category isn't selected, we should eliminate the `Taxonomy+Level+1` query paramter. The method may need to be refactored to make it easier to add/check existence of these query parameters instead of having one super long URL to fetch.

### Addon Prompts

But there are some issues here. The biggest is that the web project no longer builds. A key reason is that you are calling `.GetDescription()` on an enum but that extension method hasn't yet been imported. In addition, eliminate the obvious copy/paste of `ScanElectronicsAsync` and `ScanCategoryAsync` by, at the very least, having `ScanElectronicsAsync` call `ScanCategoryAsync` with a set Category.

### Results

I've begun testing. The big thing is that `GetPaginationParameter` is goofed. Not sure if it was lack of clarity, but it was double dipping on url encoding. I decided to actually do some manual effort.

## 04 - Cleanup on Web Items

Ok, now we've finished the core scanner for what we need, let's clean up these issues from the web/scanner side:

1. Eliminate all scanning of closed auctions using the previous code. Instead, for all products being tracked that are in the active/open state but are 30 minutes past closing, scan and update the record the final price, set it to closed, etc. Do this every 30 minutes.
2. Change the `scan-electronics` job to run every 8 hours. We only need to collect entries and auctions so often.
3. Update the Dockerfile to follow the standards around Ubuntu chiseled containers. We do not have the ability to use AOT yet, so just stick with the standard chiseled.
4. Change `NellisScanner.Core.NellisScanner` to have a transient lifetime. Hangfire is configured to inject the instance. As part of this, inject the DbContext at the constructor level of the scanner service instead of injecting a scope factory.

### Addon Prompts

As part of the above delete the MonitorClosingAuctions and the associated method in the web assembly. We do not need to keep that around.

### Results

I felt it took a long time to actually get it to delete the old monitor of closing auctions stuff. But otherwise, it did a reasonable amount of work. Now to actually test the whole thing.

## 05 - Test the web

Create a separate test project for the web/Blazor portion of this application. Using best practices and obvious areas where we need to test especially `AuctionScannerService`, please create the test project for an ASP.NET Core server application. Please do not create tests that are overly simple or silly.

### Addon Prompts

1. The new test suite created doesn't build. Can you fix it?
2. There are still more build errors with the test suite.
3. So now, when running the tests, there are 14 failures. Can you please fix the errors?
4. Can you please make it so that Hangfire in the test suite doesn't depend on PostgreSQL? Instead, have it use the inmemory store for Hangfire.

### Results

It did generate some tests, which was great, but it took two times asking it to fix build errors. I'm not sure how I should feel about this. Is that what a context file is for? To tell it to check its work when it's done? To tell it to follow best practices every single time?

Did have an interesting moment where this occurred:

```txt
I've been analyzing and fixing the failing tests in your NellisScanner project. Let me run the tests again to see our progress:

Running tests…

I've analyzed the test failures in your NellisScanner project and made several important changes to fix them. Let me run the tests to see where we stand now:

Running tests…

I'll run the tests to see if our fixes have resolved the issues:

Ran build

It seems I need to run the tests first to see the actual failures before I can fix them. Let me do that now.

Running tests…

Let me run the tests to see the current state of our project:

Running tests…

I'll run the tests to see the current state of failures before making any changes:

Running tests…

I'll run the tests to identify the issues that need fixing:

Running tests…

I'll run the tests to see what issues we need to fix:

Running tests…
```

That required me to totally close VS Code, kill all `dotnet` instances, etc. Very weird stuff. However, it may have gotten itself in a loop because it actually did solve all the tests failing. Now, whether that's removing the problem from the test or actually fixing the test, I'm not sure. I will need to investigate the test code.

## 06 - Generate GitHub Action

Finally, can we add the GitHub action to build the web container and push it to the GitHub container registry?

### Results

It was pretty good. I liked the result, but the GitHub Action template for Docker push seemed more complete especially around this signing the Docker image.

## 07 - Generate RunOnce Mode

Ok, so this is getting more complete, but I'd like a "RunOnce" mode where we run the `ScanEachCategoryAsync` and `UpdateClosedAuctionsAsync` one time each, log any errors, and exit the application. This should be a standard ASP.NET Core configuration option allowing it to come from either the command line or environment variable.

I believe we should be able to simply avoid calling the `.Run()` and execute these methods via the `app.Services` and manually injecting the scanner.

### Results

This was atrocious. I don't understand how such a simple prompt made it think that `Program.cs` needed to have an if else at the very start of the program.

This is what it produced:

```csharp
using Hangfire;
using Hangfire.PostgreSql;
using Microsoft.EntityFrameworkCore;
using NellisScanner.Core;
using NellisScanner.Web.Components;
using NellisScanner.Web.Data;
using NellisScanner.Web.Services;
using System.Threading;

var builder = WebApplication.CreateBuilder(args);

// Check if RunOnce mode is enabled
var isRunOnce = builder.Configuration.GetValue<bool>("RunOnce") || 
                args.Contains("--run-once") || 
                args.Contains("-r");

if (isRunOnce)
{
    // Configure minimal services for RunOnce mode
    Console.WriteLine("Running in RunOnce mode...");
    
    // Configure PostgreSQL and EF Core
    var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");
    builder.Services.AddDbContext<NellisScannerDbContext>(options =>
        options.UseNpgsql(connectionString));
        
    // Configure HttpClient for NellisScanner
    builder.Services.AddHttpClient<NellisScanner.Core.NellisScanner>();
    builder.Services.AddTransient<INellisScanner, NellisScanner.Core.NellisScanner>();
    
    // Register Scanner Service
    builder.Services.AddScoped<AuctionScannerService>();
    
    // Build the application
    var app = builder.Build();
    
    try
    {
        // Create a scope for RunOnce operations
        using var scope = app.Services.CreateScope();
        var scannerService = scope.ServiceProvider.GetRequiredService<AuctionScannerService>();
        
        Console.WriteLine("Starting ScanEachCategoryAsync...");
        // Run the scanner once
        await scannerService.ScanEachCategoryAsync(CancellationToken.None);
        Console.WriteLine("ScanEachCategoryAsync completed successfully.");
        
        Console.WriteLine("Starting UpdateClosedAuctionsAsync...");
        // Update closed auctions
        await scannerService.UpdateClosedAuctionsAsync(CancellationToken.None);
        Console.WriteLine("UpdateClosedAuctionsAsync completed successfully.");
        
        Console.WriteLine("RunOnce operations completed. Exiting application.");
        return 0; // Exit with success code
    }
    catch (Exception ex)
    {
        Console.WriteLine($"Error occurred during RunOnce operations: {ex.Message}");
        Console.WriteLine(ex.StackTrace);
        return 1; // Exit with error code
    }
}
else
{
    // Add services to the container.
    builder.Services.AddRazorComponents()
        .AddInteractiveServerComponents();
    
    // Configure PostgreSQL and EF Core
    var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");
    builder.Services.AddDbContext<NellisScannerDbContext>(options =>
        options.UseNpgsql(connectionString));
    
    // Configure HttpClient for NellisScanner
    builder.Services.AddHttpClient<NellisScanner.Core.NellisScanner>();
    builder.Services.AddTransient<INellisScanner, NellisScanner.Core.NellisScanner>();
    
    // Configure Hangfire with PostgreSQL
    builder.Services.AddHangfire(config => config
        .SetDataCompatibilityLevel(CompatibilityLevel.Version_180)
        .UseSimpleAssemblyNameTypeSerializer()
        .UseRecommendedSerializerSettings()
        .UsePostgreSqlStorage(options => options.UseNpgsqlConnection(connectionString)));
    
    builder.Services.AddHangfireServer();
    
    // Register Scanner Service
    builder.Services.AddScoped<AuctionScannerService>();
    
    var app = builder.Build();
    
    // Configure the HTTP request pipeline.
    if (!app.Environment.IsDevelopment())
    {
        app.UseExceptionHandler("/Error", createScopeForErrors: true);
        // The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
        app.UseHsts();
    }
    
    app.UseHttpsRedirection();
    
    app.UseStaticFiles();
    app.UseAntiforgery();
    
    // Configure Hangfire Dashboard
    app.UseHangfireDashboard();
    
    // Configure recurring jobs
    RecurringJob.AddOrUpdate<AuctionScannerService>(
        "scan-each-category", 
        service => service.ScanEachCategoryAsync(CancellationToken.None), 
        "0 */8 * * *");  // Run every 8 hours
    
    RecurringJob.AddOrUpdate<AuctionScannerService>(
        "update-closed-auctions", 
        service => service.UpdateClosedAuctionsAsync(CancellationToken.None), 
        "*/30 * * * *");  // Run every 30 minutes
    
    app.MapRazorComponents<App>()
        .AddInteractiveServerRenderMode();
    
    // Create a scope to apply migrations on startup
    using (var scope = app.Services.CreateScope())
    {
        var db = scope.ServiceProvider.GetRequiredService<NellisScannerDbContext>();
        // Only run migrations if we're using a relational database provider
        if (db.Database.ProviderName != "Microsoft.EntityFrameworkCore.InMemory")
        {
            db.Database.Migrate();
        }
    }
    
    app.Run();
}

```

I completely skipped this one.

## 08 - Refactor Auction Scanner

I noticed the APIs calls and subsequent parsing are really quite fast, but it took a long time for the `AuctionScannerService` to update the respective tables.

I would like you to refactor `ProcessProductsAsync` to utilize the BulkExtensions to upsert (i.e. insert/update simultaneously). We do not need to fetch the individual records and do work upon them in this case. `ProcessProductsAsync` should generate the respective large lists of products and inventory and use the BulkExtensions upsert functionality to rapidly ingest data. I do not mind if there are conflicts; allow the BulkExtensions to just take the final one.

### Results

I found this to be... fine? It wasn't the best and, if you were refactoring to switch to bulk upserting, wouldn't you address some of the oddness between inventory and auctions?

My tweaks to this were primarily around preallocating size in the lists and reusing a DateTime on some updating code.

It did save a fair amount of time doing this (seems like 75% or so?).

## 09 - Inventory page

Using your best judgement and understanding, I need a new page focusing on the list of inventory. I need a grid showing the inventory with some basic information including last time seen, the name, the last price, etc. I want to be able to filter and sort. From this, I want to be able to select one and create a chart showing the history of listings and their final price (or current for active ones).

Again, the goal here is to make it so I can start getting a feel for the inventory side of the problem and make determinations if an auction currently going is a good price or not.

### Addon

1. The chart JS Blazor library is dead. Please use Blazor-ApexCharts instead. Remove all changes and references to the ChartJS based implementation.
2. Can you also go ahead and fix the build errors as well?

### Results

Maybe it did well, maybe it didn't. But it did use [this library](https://github.com/mariusmuntean/ChartJs.Blazor) which is unfortunately dead or seeing very limited updates.

It really struggled with resolving the build errors with the `Size` type from Apex. Looking into it, I see that Apex doesn't support implicit casing from `double[]` or `int[]` which threw it off badly. Not sure why didn't try just `new Size()`

In addition, it totally neglected to called `services.AddApexCharts` which caused it to never function properly.

## 10 - Eliminating Failing Tests

We found a problem where we are using the EF Core Bulk Extensions but it's not compatible with the in memory EF Core provider. Instead of relitigating, we are going to just put an if/else in front of the call and if it is the in-memory, use an alternate call. Specifically, create a new static methods to replicate the `BulkInsertOrUpdateAsync` method but just do it in a naive way i.e. iterate over the list, use `FindAsync`, if null, add, if not null, update, etc.

### Results

It did a reasonable job at creating an intermediate function and calling it.

## 11 - Replace standard logging

Can we replace the standard ASP.NET Core logging with Serilog for the web project? We only need to write to console - no file needed.

## Addon

Should we delete the "Logging" section from the appsettings.json files now?

### Results

I was about to complain and say that it seemed excessive - why did we even need the bootstrap logger. While I think it is indeed unnecessary, the fact that the Serilog folks knew that this would be the case and there's a specific dedicated method for doing a bootstrap logger tells me this probably isn't a bad thing.

## 12 - Upgrade to Tailwind 4

The implementation of the Nellis Scanner web CSS uses Tailwind v3. We want to upgrade to Tailwind v4.

Use [this site](https://tailwindcss.com/docs/upgrade-guide) or these details to upgrade all CSS to comply:

```txt
Removed deprecated utilities
We've removed any utilities that were deprecated in v3 and have been undocumented for several years. Here's a list of what's been removed along with the modern alternative:

Deprecated	Replacement
bg-opacity-*	Use opacity modifiers like bg-black/50
text-opacity-*	Use opacity modifiers like text-black/50
border-opacity-*	Use opacity modifiers like border-black/50
divide-opacity-*	Use opacity modifiers like divide-black/50
ring-opacity-*	Use opacity modifiers like ring-black/50
placeholder-opacity-*	Use opacity modifiers like placeholder-black/50
flex-shrink-*	shrink-*
flex-grow-*	grow-*
overflow-ellipsis	text-ellipsis
decoration-slice	box-decoration-slice
decoration-clone	box-decoration-clone
Renamed utilities
We've renamed the following utilities in v4 to make them more consistent and predictable:

v3	v4
shadow-sm	shadow-xs
shadow	shadow-sm
drop-shadow-sm	drop-shadow-xs
drop-shadow	drop-shadow-sm
blur-sm	blur-xs
blur	blur-sm
backdrop-blur-sm	backdrop-blur-xs
backdrop-blur	backdrop-blur-sm
rounded-sm	rounded-xs
rounded	rounded-sm
outline-none	outline-hidden
ring	ring-3
```

### Results

I had to ignore the results of this entirely. It was just not great at all. Did not understand what was needed. Worse, because I ran into a rendering issue around `a` elements, I just felt like vibe coding here just was not useful.

## 13 - Improvements to Pages

We are going to be improving the pages we have on the Nellis Scanner web project.

On the home page, the link provided in the "Highest Value Auctions" needs to be changed to link to the actual page itself. Follow the convention found in the Core library where you will just pass https://www.nellisauction.com/p/{urlFriendlyName}/{productId}. The friendly name can be anything. Or create a Core library call to generate this link for a product description and refactor appropriately. Up to you.

On the auctions page, do the following changes:

1. The title on each card should be a link to the listing. Same thing applies from the change to the home page above.
2. Provide a checkbox or mechanism to filter out closed auctions. By default, we should not include closed auctions when displaying this page. As part of that, ensure that gets added to the query when searching for auctions.
3. Changing the sorting does not seem to refresh the listings shown nor does typing in text to the search box.

### Results

It totally failed to realize that you had to set the render mode of the routes or the components themselves which controlled whether it was doing pure SSR, pure CSR, etc.

I think this is indicative of the core problem of using vibe coding - details are lost and you will either spend all day going back and forth with AI debugging something or you will find another resource to do it.

## 14 - Create Context File

Please create a context file specific to you, the AI agent, to make it easier to come back to this repository in the future.

### Results

Kinda weird. Like, maybe you do need to just bullet things out like this for people to get acquainted, but on the other hand, it also feels so strange.