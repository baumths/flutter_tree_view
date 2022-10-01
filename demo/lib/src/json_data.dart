const List<Map<String, Object?>> flatJsonData = [
  {
    'id': 'A',
    'label': 'Root A',
    'parentId': null,
  },
  {
    'id': 'A 1',
    'label': 'Node A 1',
    'parentId': 'A',
  },
  {
    'id': 'A 2',
    'label': 'Node A 2',
    'parentId': 'A',
  },
  {
    'id': 'A 2 1',
    'label': 'Node A 2 1',
    'parentId': 'A 2',
  },
  {
    'id': 'B',
    'label': 'Root B',
    'parentId': null,
  },
  {
    'id': 'B 1',
    'label': 'Node B 1',
    'parentId': 'B',
  },
  {
    'id': 'B 1 1',
    'label': 'Node B 1 1',
    'parentId': 'B 1',
  },
  {
    'id': 'B 1 1 1',
    'label': 'Node B 1 1 1',
    'parentId': 'B 1 1',
  },
  {
    'id': 'B 1 1 2',
    'label': 'Node B 1 1 2',
    'parentId': 'B 1 1',
  },
  {
    'id': 'B 2',
    'label': 'Node B 2',
    'parentId': 'B',
  },
  {
    'id': 'B 2 1',
    'label': 'Node B 2 1',
    'parentId': 'B 2',
  },
  {
    'id': 'B 2 1 1',
    'label': 'Node B 2 1 1',
    'parentId': 'B 2 1',
  },
  {
    'id': 'B 3',
    'label': 'Node B 3',
    'parentId': 'B',
  },
  {
    'id': 'C',
    'label': 'Root C',
    'parentId': null,
  },
  {
    'id': 'C 1',
    'label': 'Node C 1',
    'parentId': 'C',
  },
  {
    'id': 'C 1 1',
    'label': 'Node C 1 1',
    'parentId': 'C 1',
  },
  {
    'id': 'C 2',
    'label': 'Node C 2',
    'parentId': 'C',
  },
  {
    'id': 'C 3',
    'label': 'Node C 3',
    'parentId': 'C',
  },
  {
    'id': 'C 4',
    'label': 'Node C 4',
    'parentId': 'C',
  },
  {
    'id': 'D',
    'label': 'Root D',
    'parentId': null,
  },
  {
    'id': 'D 1',
    'label': 'Node D 1',
    'parentId': 'D',
  },
  {
    'id': 'D 1 1',
    'label': 'Node D 1 1',
    'parentId': 'D 1',
  },
  {
    'id': 'E',
    'label': 'Root E',
    'parentId': null,
  },
  {
    'id': 'E 1',
    'label': 'Node E 1',
    'parentId': 'E',
  },
  {
    'id': 'F',
    'label': 'Root F',
    'parentId': null,
  },
  {
    'id': 'F 1',
    'label': 'Node F 1',
    'parentId': 'F',
  },
  {
    'id': 'F 2',
    'label': 'Node F 2',
    'parentId': 'F',
  },
];

const List<Map<String, Object?>> nestedJsonData = [
  {
    'id': 'A',
    'label': 'Root A',
    'children': [
      {
        'id': 'A 1',
        'label': 'Node A 1',
      },
      {
        'id': 'A 2',
        'label': 'Node A 2',
        'children': [
          {
            'id': 'A 2 1',
            'label': 'Node A 2 1',
          },
        ],
      },
    ],
  },
  {
    'id': 'B',
    'label': 'Root B',
    'children': [
      {
        'id': 'B 1',
        'label': 'Node B 1',
        'children': [
          {
            'id': 'B 1 1',
            'label': 'Node B 1 1',
            'children': [
              {
                'id': 'B 1 1 1',
                'label': 'Node B 1 1 1',
              },
              {
                'id': 'B 1 1 2',
                'label': 'Node B 1 1 2',
              },
            ],
          },
        ],
      },
      {
        'id': 'B 2',
        'label': 'Node B 2',
        'children': [
          {
            'id': 'B 2 1',
            'label': 'Node B 2 1',
            'children': [
              {
                'id': 'B 2 1 1',
                'label': 'Node B 2 1 1',
              },
            ],
          },
        ],
      },
      {
        'id': 'B 3',
        'label': 'Node B 3',
      },
    ],
  },
  {
    'id': 'C',
    'label': 'Root C',
    'children': [
      {
        'id': 'C 1',
        'label': 'Node C 1',
        'children': [
          {
            'id': 'C 1 1',
            'label': 'Node C 1 1',
            'parentId': 'C 1',
          },
        ],
      },
      {
        'id': 'C 2',
        'label': 'Node C 2',
      },
      {
        'id': 'C 3',
        'label': 'Node C 3',
      },
      {
        'id': 'C 4',
        'label': 'Node C 4',
      },
    ],
  },
  {
    'id': 'D',
    'label': 'Root D',
    'children': [
      {
        'id': 'D 1',
        'label': 'Node D 1',
        'children': [
          {
            'id': 'D 1 1',
            'label': 'Node D 1 1',
          },
        ]
      },
    ],
  },
  {
    'id': 'E',
    'label': 'Root E',
    'children': [
      {
        'id': 'E 1',
        'label': 'Node E 1',
      },
    ],
  },
  {
    'id': 'F',
    'label': 'Root F',
    'children': [
      {
        'id': 'F 1',
        'label': 'Node F 1',
      },
      {
        'id': 'F 2',
        'label': 'Node F 2',
      },
    ],
  },
];
