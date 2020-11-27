/// Sample data for [TreeView] demonstration
const sampleData = <Map<String, dynamic>>[
  {
    'name': '1',
    'children': <Map<String, dynamic>>[
      {'name': '1.1', 'children': <Map<String, dynamic>>[]},
      {
        'name': '1.2',
        'children': <Map<String, dynamic>>[
          {'name': '1.2.1', 'children': <Map<String, dynamic>>[]},
        ]
      },
    ],
  },
  {
    'name': '2',
    'children': <Map<String, dynamic>>[
      {
        'name': '2.1',
        'children': <Map<String, dynamic>>[
          {
            'name': '2.1.1',
            'children': <Map<String, dynamic>>[
              {
                'name': '2.1.1.1',
                'children': <Map<String, dynamic>>[
                  {'name': '2.1.1.1.1', 'children': <Map<String, dynamic>>[]},
                  {'name': '2.1.1.1.2', 'children': <Map<String, dynamic>>[]},
                ]
              },
              {'name': '2.1.1.2', 'children': <Map<String, dynamic>>[]},
            ]
          },
          {'name': '2.1.2', 'children': <Map<String, dynamic>>[]},
          {'name': '2.1.3', 'children': <Map<String, dynamic>>[]},
        ],
      },
      {
        'name': '2.2',
        'children': <Map<String, dynamic>>[
          {'name': '2.2.1', 'children': <Map<String, dynamic>>[]},
          {'name': '2.2.2', 'children': <Map<String, dynamic>>[]},
          {'name': '2.2.3', 'children': <Map<String, dynamic>>[]},
        ],
      },
    ],
  },
  {
    'name': '3',
    'children': <Map<String, dynamic>>[
      {
        'name': '3.1',
        'children': [
          {
            'name': '3.1.1',
            'children': <Map<String, dynamic>>[
              {
                'name': '3.1.1.1',
                'children': <Map<String, dynamic>>[
                  {'name': '3.1.1.1.1', 'children': <Map<String, dynamic>>[]},
                  {'name': '3.1.1.1.2', 'children': <Map<String, dynamic>>[]},
                  {'name': '3.1.1.1.3', 'children': <Map<String, dynamic>>[]}
                ]
              },
            ]
          },
          {'name': '3.1.2', 'children': <Map<String, dynamic>>[]},
          {'name': '3.1.3', 'children': <Map<String, dynamic>>[]},
        ],
      },
      {
        'name': '3.2',
        'children': <Map<String, dynamic>>[
          {'name': '3.2.1', 'children': <Map<String, dynamic>>[]},
          {'name': '3.2.2', 'children': <Map<String, dynamic>>[]},
          {'name': '3.2.3', 'children': <Map<String, dynamic>>[]},
        ],
      },
    ],
  },
];
