/*
 * This GrowERP software is in the public domain under CC0 1.0 Universal plus a
 * Grant of Patent License.
 * 
 * To the extent possible under law, the author(s) have dedicated all
 * copyright and related and neighboring rights to this software to the
 * public domain worldwide. This software is distributed without any
 * warranty.
 * 
 * You should have received a copy of the CC0 Public Domain Dedication
 * along with this software (see the LICENSE.md file). If not, see
 * <http://creativecommons.org/publicdomain/zero/1.0/>.
 */

import 'package:equatable/equatable.dart';

class Country extends Equatable {
  final String id;
  final String name;

  const Country({
    required this.id,
    required this.name,
  });

  @override
  List<Object?> get props => [
        id,
        name,
      ];
}

List<Country> countries = [
  const Country(id: "AFG", name: "Afghanistan"),
  const Country(id: "ALB", name: "Albania"),
  const Country(id: "DZA", name: "Algeria"),
  const Country(id: "ASM", name: "American Samoa"),
  const Country(id: "AND", name: "Andorra"),
  const Country(id: "AGO", name: "Angola"),
  const Country(id: "AIA", name: "Anguilla"),
  const Country(id: "ATA", name: "Antarctica"),
  const Country(id: "ATG", name: "Antigua And Barbuda"),
  const Country(id: "ARG", name: "Argentina"),
  const Country(id: "ARM", name: "Armenia"),
  const Country(id: "ABW", name: "Aruba"),
  const Country(id: "AUS", name: "Australia"),
  const Country(id: "AUT", name: "Austria"),
  const Country(id: "AZE", name: "Azerbaijan"),
  const Country(id: "BHS", name: "Bahamas"),
  const Country(id: "BHR", name: "Bahrain"),
  const Country(id: "BGD", name: "Bangladesh"),
  const Country(id: "BRB", name: "Barbados"),
  const Country(id: "BLR", name: "Belarus"),
  const Country(id: "BEL", name: "Belgium"),
  const Country(id: "BLZ", name: "Belize"),
  const Country(id: "BEN", name: "Benin"),
  const Country(id: "BMU", name: "Bermuda"),
  const Country(id: "BTN", name: "Bhutan"),
  const Country(id: "BOL", name: "Bolivia"),
  const Country(id: "BIH", name: "Bosnia And Herzegowina"),
  const Country(id: "BWA", name: "Botswana"),
  const Country(id: "BVT", name: "Bouvet Island"),
  const Country(id: "BRA", name: "Brazil"),
  const Country(id: "IOT", name: "British Indian Ocean Territory"),
  const Country(id: "BRN", name: "Brunei Darussalam"),
  const Country(id: "BGR", name: "Bulgaria"),
  const Country(id: "BFA", name: "Burkina Faso"),
  const Country(id: "BDI", name: "Burundi"),
  const Country(id: "KHM", name: "Cambodia"),
  const Country(id: "CMR", name: "Cameroon"),
  const Country(id: "CAN", name: "Canada"),
  const Country(id: "CPV", name: "Cape Verde"),
  const Country(id: "CYM", name: "Cayman Islands"),
  const Country(id: "CAF", name: "Central African Republic"),
  const Country(id: "TCD", name: "Chad"),
  const Country(id: "CHL", name: "Chile"),
  const Country(id: "CHN", name: "China"),
  const Country(id: "CXR", name: "Christmas Island"),
  const Country(id: "CCK", name: "Cocos (keeling) Islands"),
  const Country(id: "COL", name: "Colombia"),
  const Country(id: "COM", name: "Comoros"),
  const Country(id: "COG", name: "Congo"),
  const Country(id: "COD", name: "Congo, The Democratic Republic Of The"),
  const Country(id: "COK", name: "Cook Islands"),
  const Country(id: "CRI", name: "Costa Rica"),
  const Country(id: "CIV", name: "Cote D&apos;ivoire"),
  const Country(id: "HRV", name: "Croatia (local Name: Hrvatska)"),
  const Country(id: "CUB", name: "Cuba"),
  const Country(id: "CYP", name: "Cyprus"),
  const Country(id: "CZE", name: "Czech Republic"),
  const Country(id: "DNK", name: "Denmark"),
  const Country(id: "DJI", name: "Djibouti"),
  const Country(id: "DMA", name: "Dominica"),
  const Country(id: "DOM", name: "Dominican Republic"),
  const Country(id: "TLS", name: "East Timor"),
  const Country(id: "ECU", name: "Ecuador"),
  const Country(id: "EGY", name: "Egypt"),
  const Country(id: "SLV", name: "El Salvador"),
  const Country(id: "GNQ", name: "Equatorial Guinea"),
  const Country(id: "ERI", name: "Eritrea"),
  const Country(id: "EST", name: "Estonia"),
  const Country(id: "ETH", name: "Ethiopia"),
  const Country(id: "FLK", name: "Falkland Islands (malvinas)"),
  const Country(id: "FRO", name: "Faroe Islands"),
  const Country(id: "FJI", name: "Fiji"),
  const Country(id: "FIN", name: "Finland"),
  const Country(id: "FXX", name: "France, Metropolitan"),
  const Country(id: "FRA", name: "France"),
  const Country(id: "GUF", name: "French Guiana"),
  const Country(id: "PYF", name: "French Polynesia"),
  const Country(id: "ATF", name: "French Southern Territories"),
  const Country(id: "GAB", name: "Gabon"),
  const Country(id: "GMB", name: "Gambia"),
  const Country(id: "GEO", name: "Georgia"),
  const Country(id: "DEU", name: "Germany"),
  const Country(id: "GHA", name: "Ghana"),
  const Country(id: "GIB", name: "Gibraltar"),
  const Country(id: "GRC", name: "Greece"),
  const Country(id: "GRL", name: "Greenland"),
  const Country(id: "GRD", name: "Grenada"),
  const Country(id: "GLP", name: "Guadeloupe"),
  const Country(id: "GUM", name: "Guam"),
  const Country(id: "GTM", name: "Guatemala"),
  const Country(id: "GIN", name: "Guinea"),
  const Country(id: "GNB", name: "Guinea-bissau"),
  const Country(id: "GUY", name: "Guyana"),
  const Country(id: "HTI", name: "Haiti"),
  const Country(id: "HMD", name: "Heard And Mc Donald Islands"),
  const Country(id: "VAT", name: "Holy See (vatican City State)"),
  const Country(id: "HND", name: "Honduras"),
  const Country(id: "HKG", name: "Hong Kong"),
  const Country(id: "HUN", name: "Hungary"),
  const Country(id: "ISL", name: "Iceland"),
  const Country(id: "IND", name: "India"),
  const Country(id: "IDN", name: "Indonesia"),
  const Country(id: "IRN", name: "Iran (islamic Republic Of)"),
  const Country(id: "IRQ", name: "Iraq"),
  const Country(id: "IRL", name: "Ireland"),
  const Country(id: "ISR", name: "Israel"),
  const Country(id: "ITA", name: "Italy"),
  const Country(id: "JAM", name: "Jamaica"),
  const Country(id: "JPN", name: "Japan"),
  const Country(id: "JOR", name: "Jordan"),
  const Country(id: "KAZ", name: "Kazakhstan"),
  const Country(id: "KEN", name: "Kenya"),
  const Country(id: "KIR", name: "Kiribati"),
  const Country(id: "PRK", name: "Korea, Democratic People&apos;s Republic Of"),
  const Country(id: "KOR", name: "Korea, Republic Of"),
  const Country(id: "KWT", name: "Kuwait"),
  const Country(id: "KGZ", name: "Kyrgyzstan"),
  const Country(id: "LAO", name: "Lao People&apos;s Democratic Republic"),
  const Country(id: "LVA", name: "Latvia"),
  const Country(id: "LBN", name: "Lebanon"),
  const Country(id: "LSO", name: "Lesotho"),
  const Country(id: "LBR", name: "Liberia"),
  const Country(id: "LBY", name: "Libyan Arab Jamahiriya"),
  const Country(id: "LIE", name: "Liechtenstein"),
  const Country(id: "LTU", name: "Lithuania"),
  const Country(id: "LUX", name: "Luxembourg"),
  const Country(id: "MAC", name: "Macau"),
  const Country(id: "MKD", name: "Macedonia, The Former Yugoslav Republic Of"),
  const Country(id: "MDG", name: "Madagascar"),
  const Country(id: "MWI", name: "Malawi"),
  const Country(id: "MYS", name: "Malaysia"),
  const Country(id: "MDV", name: "Maldives"),
  const Country(id: "MLI", name: "Mali"),
  const Country(id: "MLT", name: "Malta"),
  const Country(id: "MHL", name: "Marshall Islands"),
  const Country(id: "MTQ", name: "Martinique"),
  const Country(id: "MRT", name: "Mauritania"),
  const Country(id: "MUS", name: "Mauritius"),
  const Country(id: "MYT", name: "Mayotte"),
  const Country(id: "MEX", name: "Mexico"),
  const Country(id: "FSM", name: "Micronesia, Federated States Of"),
  const Country(id: "MDA", name: "Moldova, Republic Of"),
  const Country(id: "MCO", name: "Monaco"),
  const Country(id: "MNG", name: "Mongolia"),
  const Country(id: "MNE", name: "Montenegro"),
  const Country(id: "MSR", name: "Montserrat"),
  const Country(id: "MAR", name: "Morocco"),
  const Country(id: "MOZ", name: "Mozambique"),
  const Country(id: "MMR", name: "Myanmar"),
  const Country(id: "NAM", name: "Namibia"),
  const Country(id: "NRU", name: "Nauru"),
  const Country(id: "NPL", name: "Nepal"),
  const Country(id: "NLD", name: "Netherlands"),
  const Country(id: "ANT", name: "Netherlands Antilles"),
  const Country(id: "NCL", name: "New Caledonia"),
  const Country(id: "NZL", name: "New Zealand"),
  const Country(id: "NIC", name: "Nicaragua"),
  const Country(id: "NER", name: "Niger"),
  const Country(id: "NGA", name: "Nigeria"),
  const Country(id: "NIU", name: "Niue"),
  const Country(id: "NFK", name: "Norfolk Island"),
  const Country(id: "MNP", name: "Northern Mariana Islands"),
  const Country(id: "NOR", name: "Norway"),
  const Country(id: "OMN", name: "Oman"),
  const Country(id: "PAK", name: "Pakistan"),
  const Country(id: "PLW", name: "Palau"),
  const Country(id: "PSE", name: "Palestinian Territory, Occupied"),
  const Country(id: "PAN", name: "Panama"),
  const Country(id: "PNG", name: "Papua New Guinea"),
  const Country(id: "PRY", name: "Paraguay"),
  const Country(id: "PER", name: "Peru"),
  const Country(id: "PHL", name: "Philippines"),
  const Country(id: "PCN", name: "Pitcairn"),
  const Country(id: "POL", name: "Poland"),
  const Country(id: "PRT", name: "Portugal"),
  const Country(id: "PRI", name: "Puerto Rico"),
  const Country(id: "QAT", name: "Qatar"),
  const Country(id: "REU", name: "Reunion"),
  const Country(id: "ROU", name: "Romania"),
  const Country(id: "RUS", name: "Russian Federation"),
  const Country(id: "RWA", name: "Rwanda"),
  const Country(id: "KNA", name: "Saint Kitts And Nevis"),
  const Country(id: "LCA", name: "Saint Lucia"),
  const Country(id: "VCT", name: "Saint Vincent And The Grenadines"),
  const Country(id: "WSM", name: "Samoa"),
  const Country(id: "SMR", name: "San Marino"),
  const Country(id: "STP", name: "Sao Tome And Principe"),
  const Country(id: "SAU", name: "Saudi Arabia"),
  const Country(id: "SEN", name: "Senegal"),
  const Country(id: "SRB", name: "Serbia"),
  const Country(id: "SYC", name: "Seychelles"),
  const Country(id: "SLE", name: "Sierra Leone"),
  const Country(id: "SGP", name: "Singapore"),
  const Country(id: "SVK", name: "Slovakia (slovak Republic)"),
  const Country(id: "SVN", name: "Slovenia"),
  const Country(id: "SLB", name: "Solomon Islands"),
  const Country(id: "SOM", name: "Somalia"),
  const Country(
      id: "SGS", name: "South Georgia And The South Sandwich Islands"),
  const Country(id: "ZAF", name: "South Africa"),
  const Country(id: "ESP", name: "Spain"),
  const Country(id: "LKA", name: "Sri Lanka"),
  const Country(id: "SHN", name: "St. Helena"),
  const Country(id: "SPM", name: "St. Pierre And Miquelon"),
  const Country(id: "SDN", name: "Sudan"),
  const Country(id: "SUR", name: "Suriname"),
  const Country(id: "SJM", name: "Svalbard And Jan Mayen Islands"),
  const Country(id: "SWZ", name: "Swaziland"),
  const Country(id: "SWE", name: "Sweden"),
  const Country(id: "CHE", name: "Switzerland"),
  const Country(id: "SYR", name: "Syrian Arab Republic"),
  const Country(id: "TWN", name: "Taiwan"),
  const Country(id: "TJK", name: "Tajikistan"),
  const Country(id: "TZA", name: "Tanzania, United Republic Of"),
  const Country(id: "THA", name: "Thailand"),
  const Country(id: "TGO", name: "Togo"),
  const Country(id: "TKL", name: "Tokelau"),
  const Country(id: "TON", name: "Tonga"),
  const Country(id: "TTO", name: "Trinidad And Tobago"),
  const Country(id: "TUN", name: "Tunisia"),
  const Country(id: "TUR", name: "Turkey"),
  const Country(id: "TKM", name: "Turkmenistan"),
  const Country(id: "TCA", name: "Turks And Caicos Islands"),
  const Country(id: "TUV", name: "Tuvalu"),
  const Country(id: "UGA", name: "Uganda"),
  const Country(id: "UKR", name: "Ukraine"),
  const Country(id: "USA", name: "United States"),
  const Country(id: "UMI", name: "United States Minor Outlying Islands"),
  const Country(id: "ARE", name: "United Arab Emirates"),
  const Country(id: "GBR", name: "United Kingdom"),
  const Country(id: "URY", name: "Uruguay"),
  const Country(id: "UZB", name: "Uzbekistan"),
  const Country(id: "VUT", name: "Vanuatu"),
  const Country(id: "VEN", name: "Venezuela"),
  const Country(id: "VNM", name: "Viet Nam"),
  const Country(id: "VGB", name: "Virgin Islands (british)"),
  const Country(id: "VIR", name: "Virgin Islands (u.s.)"),
  const Country(id: "WLF", name: "Wallis And Futuna Islands"),
  const Country(id: "ESH", name: "Western Sahara"),
  const Country(id: "YEM", name: "Yemen"),
  const Country(id: "YUG", name: "Yugoslavia"),
  const Country(id: "ZMB", name: "Zambia"),
  const Country(id: "ZWE", name: "Zimbabwe"),
];
