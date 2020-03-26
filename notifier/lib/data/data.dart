import 'package:notifier/model/options.dart';

// const selectionData= {
//     "councils": ["ss", "snt", "gns", "anc", "mnc"],
//     "clubs": ["Aeromodelling Club", "Astronomy Club", "Electronics Club", "Robotics Club", "Programming Club", "Speedcubing Club", "Finance and Analytics Club"],
//     "hobby": ["ScienceCoffeeHouse", "DESCON", "Consulting Group"],
//     "division": ["Web Division", "Outreach and Connect", "Product Development Society"],
//     "teams": ["Aerial Robotics", "AUV", "IITK Motorsports", "ERA IITK", "Vision", "ZURA", "Humanoid", "iGEM", "Robocon"],
//     "misc": ["Science and Technology Council", "Techkriti"]
// };

// List<Options> selectionData = [
//   // Options("Council",["ss", "snt", "gns", "anc", "mnc"]),
//   Options('Club',  ["Aeromodelling Club", "Astronomy Club", "Electronics Club", "Robotics Club", "Programming Club", "Speedcubing Club", "Finance and Analytics Club"]),
//   Options('Hobby', ["ScienceCoffeeHouse", "DESCON", "Consulting Group"]),
//   Options("Division", ["Web Division", "Outreach and Connect", "Product Development Society"]),
//   Options( "Team", ["Aerial Robotics", "AUV", "IITK Motorsports", "ERA IITK", "Vision", "ZURA", "Humanoid", "iGEM", "Robocon"],),
//   // Options( "Misc", ["Science and Technology Council", "Techkriti"]),
// ];
List<Options> selectionData = [
  // Options("Council",["ss", "snt", "gns", "anc", "mnc"]),
  Options(
    'Choose..',
    [
      "Aeromodelling Club",
      "Astronomy Club",
      "Electronics Club",
      "Robotics Club",
      "Programming Club",
      "Speedcubing Club",
      "Finance and Analytics Club",
      "Aerial Robotics",
      "AUV",
      "Game Development Society",
      "IITK Motorsports",
      "ERA IITK",
      "Vision",
      "ZURA",
      "Humanoid",
      "iGEM",
      "Robocon"
    ],
    [false,
    false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,
    ]
  ),
  // Options( "Misc", ["Science and Technology Council", "Techkriti"]),
];
// List<String> selection

class Repository {
  List<Map> getAll() => _selectionData;

  getLocalByState(String state) => null;

  List<String> getStates() => null;

  List _selectionData = [
    // {
    //   'title' : "councils",
    //   'options': ["ss", "snt", "gns", "anc", "mnc"]
    // },
    {
      'title': "clubs",
      'options': [
        "Aeromodelling Club",
        "Astronomy Club",
        "Electronics Club",
        "Robotics Club",
        "Programming Club",
        "Speedcubing Club",
        "Finance and Analytics Club"
      ],
    },
    {
      'title': "hobby",
      'options': ["ScienceCoffeeHouse", "DESCON", "Consulting Group"],
    },
    {
      'title': "division",
      'options': [
        "Web Division",
        "Outreach and Connect",
        "Product Development Society"
      ],
    },
    {
      'title': "teams",
      'options': [
        "Aerial Robotics",
        "AUV",
        "IITK Motorsports",
        "ERA IITK",
        "Vision",
        "ZURA",
        "Humanoid",
        "iGEM",
        "Robocon"
      ]
    }

    // "misc": ["Science and Technology Council", "Techkriti"]
  ];
}
