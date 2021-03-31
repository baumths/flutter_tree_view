/// Sample data for [TreeView] example.
const sampleData = <Map<String, Object>>[
  {
    'id': 1,
    'name': '1',
    'children': <Map<String, Object>>[
      {
        'id': 11,
        'name': '1.1',
        'children': <Map<String, Object>>[],
      },
      {
        'id': 12,
        'name': '1.2',
        'children': <Map<String, Object>>[
          {
            'id': 121,
            'name': '1.2.1',
            'children': <Map<String, Object>>[],
          },
        ]
      },
    ],
  },
  {
    'id': 2,
    'name': '2',
    'children': <Map<String, Object>>[
      {
        'id': 21,
        'name': '2.1',
        'children': <Map<String, Object>>[
          {
            'id': 211,
            'name': '2.1.1',
            'children': <Map<String, Object>>[
              {
                'id': 2111,
                'name': '2.1.1.1',
                'children': <Map<String, Object>>[
                  {
                    'id': 21111,
                    'name': '2.1.1.1.1',
                    'children': <Map<String, Object>>[],
                  },
                  {
                    'id': 21112,
                    'name': '2.1.1.1.2',
                    'children': <Map<String, Object>>[],
                  },
                ]
              },
              {
                'id': 2112,
                'name': '2.1.1.2',
                'children': <Map<String, Object>>[],
              },
            ]
          },
          {
            'id': 212,
            'name': '2.1.2',
            'children': <Map<String, Object>>[],
          },
          {
            'id': 213,
            'name': '2.1.3',
            'children': <Map<String, Object>>[],
          },
        ],
      },
      {
        'id': 22,
        'name': '2.2',
        'children': <Map<String, Object>>[
          {
            'id': 221,
            'name': '2.2.1',
            'children': <Map<String, Object>>[],
          },
          {
            'id': 222,
            'name': '2.2.2',
            'children': <Map<String, Object>>[],
          },
          {
            'id': 223,
            'name': '2.2.3',
            'children': <Map<String, Object>>[],
          },
        ],
      },
    ],
  },
  {
    'id': 3,
    'name': '3',
    'children': <Map<String, Object>>[
      {
        'id': 31,
        'name': '3.1',
        'children': [
          {
            'id': 311,
            'name': '3.1.1',
            'children': <Map<String, Object>>[
              {
                'id': 3111,
                'name': '3.1.1.1',
                'children': <Map<String, Object>>[
                  {
                    'id': 31111,
                    'name': '3.1.1.1.1',
                    'children': <Map<String, Object>>[],
                  },
                  {
                    'id': 31112,
                    'name': '3.1.1.1.2',
                    'children': <Map<String, Object>>[],
                  },
                  {
                    'id': 31113,
                    'name': '3.1.1.1.3',
                    'children': <Map<String, Object>>[],
                  }
                ]
              },
            ]
          },
          {
            'id': 312,
            'name': '3.1.2',
            'children': <Map<String, Object>>[],
          },
          {
            'id': 313,
            'name': '3.1.3',
            'children': <Map<String, Object>>[],
          },
        ],
      },
      {
        'id': 32,
        'name': '3.2',
        'children': <Map<String, Object>>[
          {
            'id': 321,
            'name': '3.2.1',
            'children': <Map<String, Object>>[],
          },
          {
            'id': 322,
            'name': '3.2.2',
            'children': <Map<String, Object>>[],
          },
          {
            'id': 323,
            'name': '3.2.3',
            'children': <Map<String, Object>>[],
          },
        ],
      },
    ],
  },
];
