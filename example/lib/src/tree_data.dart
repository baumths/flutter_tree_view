void generateTreeNodes<T>(T root, T Function(T, String) addNewChild) {
  void traverse(T node, Map map) {
    for (final MapEntry(:key, :value) in map.entries) {
      final child = addNewChild(node, key);
      traverse(child, value);
    }
  }

  traverse(root, geographicalLocationsTree);
}

const geographicalLocationsTree = {
  "🌍  Africa": {
    "🇪🇬  Egypt": {
      "🏙️  Cairo": {},
      "🏙️  Alexandria": {},
    },
    "🇿🇦  South Africa": {
      "🏙️  Cape Town": {},
      "🏙️  Johannesburg": {},
    },
    "🇳🇬  Nigeria": {
      "🏙️  Lagos": {},
      "🏙️  Abuja": {},
    },
    "🇰🇪  Kenya": {
      "🏞️  Mombasa": {
        "🏖️  Mombasa": {},
      },
      "🏞️  Rift Valley": {
        "🏙️  Nakuru": {},
        "🏙️  Eldoret": {},
      },
      "🏙️  Nairobi": {}
    },
    "🇲🇦  Morocco": {
      "🏞️  Casablanca": {
        "🏙️  Casablanca": {},
      },
      "🏞️  Marrakech": {
        "🏙️  Marrakech": {},
      },
      "🏙️  Rabat": {}
    },
    "🇿🇲  Zambia": {
      "🏞️  Copperbelt": {
        "🏙️  Kitwe": {},
        "🏙️  Ndola": {},
      },
      "🏙️  Lusaka": {}
    }
  },
  "🌎  Americas": {
    "🌎  Central America": {
      "🇬🇹  Guatemala": {
        "🏙️  Guatemala City": {},
        "🏞️  Antigua Guatemala": {}
      },
      "🇧🇿  Belize": {
        "🏙️  Belize City": {},
        "🏖️  San Pedro": {},
      },
      "🇸🇻  El Salvador": {
        "🏙️  San Salvador": {},
        "🏞️  Santa Ana": {},
      },
      "🇭🇳  Honduras": {
        "🏙️  Tegucigalpa": {},
        "🏞️  San Pedro Sula": {},
      },
      "🇳🇮  Nicaragua": {
        "🏙️  Managua": {},
        "🏞️  Granada": {},
      },
      "🇨🇷  Costa Rica": {
        "🏙️  San José": {},
        "🏞️  Limón": {},
        "🏖️  Jacó": {}
      },
      "🇵🇦  Panama": {
        "🏙️  Panama City": {},
        "🏖️  Bocas del Toro": {},
      }
    },
    "🌎  North America": {
      "🇺🇸  United States": {
        "🏞️  California": {
          "🏙️  Los Angeles": {},
          "🏙️  San Francisco": {},
        },
        "🏞️  New York": {
          "🏙️  New York City": {},
          "🌆  Buffalo": {},
        },
        "🏞️  Texas": {
          "🏙️  Houston": {},
          "🏙️  Dallas": {},
        },
        "🏞️  Florida": {
          "🏙️  Miami": {},
          "🏙️  Orlando": {},
          "🏖️  Key West": {}
        },
        "🏞️  Illinois": {
          "🏙️  Chicago": {},
        },
        "🏞️  Nevada": {
          "🏙️  Las Vegas": {},
        }
      },
      "🇨🇦  Canada": {
        "🏞️  Alberta": {
          "🏙️  Edmonton": {},
          "🏙️  Calgary": {},
        },
        "🏞️  Nova Scotia": {
          "🏙️  Halifax": {},
        },
        "🏞️  Ontario": {
          "🏙️  Toronto": {},
          "🏙️  Ottawa": {},
        },
        "🏞️  Quebec": {
          "🏙️  Montreal": {},
          "🏙️  Quebec City": {},
        },
        "🏞️  British Columbia": {
          "🏙️  Vancouver": {},
          "🏙️  Victoria": {},
        }
      },
      "🇲🇽  Mexico": {
        "🏞️  Baja California": {
          "🏙️  Tijuana": {},
          "🏙️  Mexicali": {},
        },
        "🏞️  Jalisco": {
          "🏙️  Guadalajara": {},
        },
        "🏙️  Mexico City": {},
        "🏖️  Cancun": {}
      }
    },
    "🌎  South America": {
      "🇧🇷  Brazil": {
        "🏞️  Rio de Janeiro": {
          "🏖️  Rio de Janeiro": {},
        },
        "🏙️  Sao Paulo": {},
      },
      "🇦🇷  Argentina": {
        "🏙️  Buenos Aires": {},
        "🏙️  Cordoba": {},
      },
      "🇨🇱  Chile": {
        "🏙️  Santiago": {},
        "🏙️  Valparaiso": {},
      },
      "🇨🇴  Colombia": {
        "🏙️  Bogotá": {},
        "🏙️  Medellin": {},
      },
      "🇵🇪  Peru": {
        "🏙️  Lima": {},
        "🏙️  Cusco": {},
      }
    }
  },
  "🌏  Antarctica": {
    "🏔️  Research Stations": {
      "🔬  McMurdo Station": {},
      "🔬  Amundsen-Scott South Pole Station": {},
      "🔬  Palmer Station": {}
    },
    "🏞️  Significant Ice Shelves": {
      "🧊  Ross Ice Shelf": {},
      "🧊  Filchner-Ronne Ice Shelf": {}
    }
  },
  "🌏  Asia": {
    "🇨🇳  China": {
      "🏙️  Beijing": {},
      "🏙️  Shanghai": {},
    },
    "🇮🇳  India": {
      "🏙️  New Delhi": {},
      "🏙️  Mumbai": {},
    },
    "🇯🇵  Japan": {
      "🏙️  Tokyo": {},
      "🏙️  Osaka": {},
    },
    "🇹🇭  Thailand": {
      "🏙️  Bangkok": {},
      "🏞️  Chiang Mai": {},
      "🏖️  Phuket": {}
    },
    "🇻🇳  Vietnam": {
      "🏙️  Hanoi": {},
      "🏙️  Ho Chi Minh City": {},
      "🏞️  Da Nang": {}
    },
    "🇲🇾  Malaysia": {
      "🏞️  Sabah": {
        "🏖️  Kota Kinabalu": {},
      },
      "🏙️  Kuala Lumpur": {},
      "🏙️  George Town": {}
    }
  },
  "🌏  Australia & Oceania": {
    "🇦🇺  Australia": {
      "🏞️  New South Wales": {
        "🏙️  Sydney": {},
      },
      "🏞️  Victoria": {
        "🏙️  Melbourne": {},
      },
      "🏞️  Queensland": {
        "🏙️  Brisbane": {},
        "🏖️  Gold Coast": {},
      },
      "🏞️  Western Australia": {
        "🏙️  Perth": {},
      },
      "🏞️  Tasmania": {
        "🏙️  Hobart": {},
      }
    },
    "🇳🇿  New Zealand": {
      "🏞️  Canterbury": {
        "🏙️  Christchurch": {},
      },
      "🏞️  Otago": {
        "🏙️  Dunedin": {},
      },
      "🏞️  North Island": {
        "🏙️  Wellington": {},
      },
      "🏙️  Auckland": {},
      "🏙️  Wellington": {}
    },
    "🇫🇯  Fiji": {
      "🏙️  Suva": {},
      "🏖️  Nadi": {},
    }
  },
  "🌍  Europe": {
    "🇫🇷  France": {
      "🏞️  Île-de-France": {
        "🏙️  Paris": {},
      },
      "🏞️  Provence-Alpes-Côte d'Azur": {
        "🏙️  Marseille": {},
        "🏙️  Nice": {},
      }
    },
    "🇩🇪  Germany": {
      "🏞️  Bavaria": {
        "🏙️  Munich": {},
      },
      "🏞️  Berlin": {
        "🏙️  Berlin": {},
      }
    },
    "🇮🇹  Italy": {
      "🏞️  Lazio": {
        "🏙️  Rome": {},
      },
      "🏞️  Tuscany": {
        "🏙️  Florence": {},
      }
    },
    "🇪🇸  Spain": {
      "🏞️  Catalonia": {
        "🏙️  Barcelona": {},
      },
      "🏞️  Madrid": {
        "🏙️  Madrid": {},
      },
      "🏞️  Andalusia": {
        "🏙️  Seville": {},
        "🏖️  Malaga": {},
      },
    }
  }
};
