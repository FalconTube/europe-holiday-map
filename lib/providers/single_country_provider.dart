import 'dart:convert';

import 'package:countries_world_map/data/maps/world_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:countries_world_map/countries_world_map.dart';
import 'package:holiday_map/logging/logger.dart';
import 'package:holiday_map/main.dart';

// Map for access of data
class MapCountryData {
  final String country;
  String instruction;
  // List<String> codes;
  final List<Map<String, dynamic>> properties;
  Map<String, Color?> keyValuesPaires;

  MapCountryData({
    required this.country,
    required this.instruction,
    // required this.codes,
    required this.properties,
    required this.keyValuesPaires,
  });
}

// Provider for consumption
final singleCountryProvider =
    StateNotifierProvider.family<SingleCountryProvider, MapCountryData, String>(
        (ref, country) {
  return SingleCountryProvider(country);
});

// State
class SingleCountryProvider extends StateNotifier<MapCountryData> {
  SingleCountryProvider(String country) : super(initState(country));

  Future<void> resetData() async {
    state = initState(state.country);
  }

  Future<void> updateSingleID(String id) async {
    if (id == "") return;
    int i = state.properties.indexWhere((element) => element['id'] == id);

    state.properties[i]['color'] = Colors.deepPurple;
    state.keyValuesPaires[state.properties[i]['id']] =
        state.properties[i]['color'];
    state = MapCountryData(
        country: state.country,
        instruction: state.instruction,
        properties: state.properties,
        keyValuesPaires: state.keyValuesPaires);
  }

  // Future<void> updateMultipleIDs(List<String> ids) async {
  Future<void> updateMultipleIDs(IsoAndCodeResults potentialIds) async {
    if (potentialIds.iso.isEmpty && potentialIds.code.isEmpty) return;

    // Check if iso or normal code
    final countryCodes = getCodes(state.country);
    bool isIso = true;
    for (final code in countryCodes) {
      if (potentialIds.code.keys.toList().contains(code)) {
        // Found normal code
        isIso = false;

        break;
      }
    }
    Map<String, String?> codesToUse =
        isIso ? potentialIds.iso : potentialIds.code;
    for (final id in codesToUse.keys.toList()) {
      if (id == "") continue;
      int i = state.properties.indexWhere((element) => element['id'] == id);

      state.properties[i]['color'] = Colors.deepPurple;
      state.keyValuesPaires[state.properties[i]['id']] =
          state.properties[i]['color'];
    }
    state = MapCountryData(
        country: state.country,
        instruction: state.instruction,
        properties: state.properties,
        keyValuesPaires: state.keyValuesPaires);
  }

  static String getInstructions(String id) {
    switch (id) {
      case 'world':
        return SMapWorld.instructions;

      case 'ar':
        return SMapArgentina.instructions;

      case 'at':
        return SMapAustria.instructions;

      case 'ad':
        return SMapAndorra.instructions;

      case 'ao':
        return SMapAngola.instructions;

      case 'am':
        return SMapArmenia.instructions;

      case 'au':
        return SMapAustralia.instructions;

      case 'az':
        return SMapAzerbaijan.instructions;

      case 'bs':
        return SMapBahamas.instructions;

      case 'bh':
        return SMapBahrain.instructions;

      case 'bd':
        return SMapBangladesh.instructions;

      case 'by':
        return SMapBelarus.instructions;

      case 'be':
        return SMapBelgium.instructions;

      case 'bt':
        return SMapBhutan.instructions;

      case 'bo':
        return SMapBolivia.instructions;

      case 'bw':
        return SMapBotswana.instructions;

      case 'br':
        return SMapBrazil.instructions;

      case 'bn':
        return SMapBrunei.instructions;

      case 'bg':
        return SMapBulgaria.instructions;

      case 'bf':
        return SMapBurkinaFaso.instructions;

      case 'bi':
        return SMapBurundi.instructions;

      case 'ca':
        return SMapCanada.instructions;

      case 'cm':
        return SMapCameroon.instructions;

      case 'cf':
        return SMapCentralAfricanRepublic.instructions;

      case 'cv':
        return SMapCapeVerde.instructions;

      case 'td':
        return SMapChad.instructions;

      case 'cn':
        return SMapChina.instructions;

      case 'ch':
        return SMapSwitzerland.instructions;

      case 'cd':
        return SMapCongoDR.instructions;

      case 'cg':
        return SMapCongoBrazzaville.instructions;

      case 'co':
        return SMapColombia.instructions;

      case 'cr':
        return SMapCostaRica.instructions;

      case 'hr':
        return SMapCroatia.instructions;

      case 'cu':
        return SMapCuba.instructions;

      case 'cl':
        return SMapChile.instructions;

      case 'ci':
        return SMapIvoryCoast.instructions;

      case 'cy':
        return SMapCyprus.instructions;

      case 'cz':
        return SMapCzechRepublic.instructions;

      case 'dk':
        return SMapDenmark.instructions;

      case 'dj':
        return SMapDjibouti.instructions;

      case 'do':
        return SMapDominicanRepublic.instructions;

      case 'ec':
        return SMapEcuador.instructions;

      case 'es':
        return SMapSpain.instructions;

      case 'eg':
        return SMapEgypt.instructions;

      case 'et':
        return SMapEthiopia.instructions;

      case 'sv':
        return SMapElSalvador.instructions;

      case 'ee':
        return SMapEstonia.instructions;

      case 'fo':
        return SMapFaroeIslands.instructions;

      case 'fi':
        return SMapFinland.instructions;

      case 'fr':
        return SMapFrance.instructions;

      case 'gb':
        return SMapUnitedKingdom.instructions;

      case 'ge':
        return SMapGeorgia.instructions;

      case 'de':
        return SMapGermany.instructions;

      case 'gr':
        return SMapGreece.instructions;

      case 'gt':
        return SMapGuatemala.instructions;

      case 'gn':
        return SMapGuinea.instructions;

      case 'hi':
        return SMapHaiti.instructions;

      case 'hk':
        return SMapHongKong.instructions;

      case 'hn':
        return SMapHonduras.instructions;

      case 'hu':
        return SMapHungary.instructions;

      case 'in':
        return SMapIndia.instructions;

      case 'id':
        return SMapIndonesia.instructions;

      case 'il':
        return SMapIsrael.instructions;

      case 'ir':
        return SMapIran.instructions;

      case 'iq':
        return SMapIraq.instructions;

      case 'ie':
        return SMapIreland.instructions;

      case 'it':
        return SMapItaly.instructions;

      case 'jm':
        return SMapJamaica.instructions;

      case 'jp':
        return SMapJapan.instructions;

      case 'kz':
        return SMapKazakhstan.instructions;

      case 'ke':
        return SMapKenya.instructions;

      case 'xk':
        return SMapKosovo.instructions;

      case 'kg':
        return SMapKyrgyzstan.instructions;

      case 'la':
        return SMapLaos.instructions;

      case 'lv':
        return SMapLatvia.instructions;

      case 'li':
        return SMapLiechtenstein.instructions;

      case 'lt':
        return SMapLithuania.instructions;

      case 'lu':
        return SMapLuxembourg.instructions;

      case 'mk':
        return SMapMacedonia.instructions;

      case 'ml':
        return SMapMali.instructions;

      case 'mt':
        return SMapMalta.instructions;

      case 'mz':
        return SMapMozambique.instructions;

      case 'mx':
        return SMapMexico.instructions;

      case 'md':
        return SMapMoldova.instructions;

      case 'me':
        return SMapMontenegro.instructions;

      case 'ma':
        return SMapMorocco.instructions;

      case 'mm':
        return SMapMyanmar.instructions;

      case 'my':
        return SMapMalaysia.instructions;

      case 'na':
        return SMapNamibia.instructions;

      case 'np':
        return SMapNepal.instructions;

      case 'nl':
        return SMapNetherlands.instructions;

      case 'nz':
        return SMapNewZealand.instructions;

      case 'ni':
        return SMapNicaragua.instructions;

      case 'ng':
        return SMapNigeria.instructions;

      case 'no':
        return SMapNorway.instructions;

      case 'om':
        return SMapOman.instructions;

      case 'ps':
        return SMapPalestine.instructions;

      case 'pk':
        return SMapPakistan.instructions;

      case 'ph':
        return SMapPhilippines.instructions;

      case 'pa':
        return SMapPanama.instructions;

      case 'pe':
        return SMapPeru.instructions;

      case 'pr':
        return SMapPuertoRico.instructions;

      case 'py':
        return SMapParaguay.instructions;

      case 'pl':
        return SMapPoland.instructions;

      case 'pt':
        return SMapPortugal.instructions;

      case 'qa':
        return SMapQatar.instructions;

      case 'ro':
        return SMapRomania.instructions;

      case 'ru':
        return SMapRussia.instructions;

      case 'rw':
        return SMapRwanda.instructions;

      case 'sa':
        return SMapSaudiArabia.instructions;

      case 'rs':
        return SMapSerbia.instructions;

      case 'sd':
        return SMapSudan.instructions;

      case 'sg':
        return SMapSingapore.instructions;

      case 'sl':
        return SMapSierraLeone.instructions;

      case 'sk':
        return SMapSlovakia.instructions;

      case 'si':
        return SMapSlovenia.instructions;

      case 'kr':
        return SMapSouthKorea.instructions;

      case 'lk':
        return SMapSriLanka.instructions;

      case 'se':
        return SMapSweden.instructions;

      case 'sy':
        return SMapSyria.instructions;

      case 'tw':
        return SMapTaiwan.instructions;

      case 'tj':
        return SMapTajikistan.instructions;

      case 'th':
        return SMapThailand.instructions;

      case 'tr':
        return SMapTurkey.instructions;

      case 'ug':
        return SMapUganda.instructions;

      case 'ua':
        return SMapUkraine.instructions;

      case 'ae':
        return SMapUnitedArabEmirates.instructions;

      case 'us':
        return SMapUnitedStates.instructions;

      case 'uy':
        return SMapUruguay.instructions;

      case 'uz':
        return SMapUzbekistan.instructions;

      case 've':
        return SMapVenezuela.instructions;

      case 'vn':
        return SMapVietnam.instructions;

      case 'ye':
        return SMapYemen.instructions;

      case 'za':
        return SMapSouthAfrica.instructions;

      case 'zm':
        return SMapZambia.instructions;

      case 'zw':
        return SMapZimbabwe.instructions;

      default:
        return 'NOT SUPPORTED';
    }
  }

  static List<String> getCodes(String id) {
    switch (id) {
      case 'world':
        return SMapWorldColors().toMap().keys.toList();

      case 'ar':
        return SMapArgentinaColors().toMap().keys.toList();

      case 'at':
        return SMapAustriaColors().toMap().keys.toList();

      case 'ad':
        return SMapAndorraColors().toMap().keys.toList();

      case 'ao':
        return SMapAngolaColors().toMap().keys.toList();

      case 'am':
        return SMapArmeniaColors().toMap().keys.toList();

      case 'au':
        return SMapAustraliaColors().toMap().keys.toList();

      case 'az':
        return SMapAzerbaijanColors().toMap().keys.toList();

      case 'bs':
        return SMapBahamasColors().toMap().keys.toList();

      case 'bh':
        return SMapBahrainColors().toMap().keys.toList();

      case 'bd':
        return SMapBangladeshColors().toMap().keys.toList();

      case 'by':
        return SMapBelarusColors().toMap().keys.toList();

      case 'be':
        return SMapBelgiumColors().toMap().keys.toList();

      case 'bt':
        return SMapBhutanColors().toMap().keys.toList();

      case 'bo':
        return SMapBoliviaColors().toMap().keys.toList();

      case 'bw':
        return SMapBotswanaColors().toMap().keys.toList();

      case 'br':
        return SMapBrazilColors().toMap().keys.toList();

      case 'bn':
        return SMapBruneiColors().toMap().keys.toList();

      case 'bg':
        return SMapBulgariaColors().toMap().keys.toList();

      case 'bf':
        return SMapBurkinaFasoColors().toMap().keys.toList();

      case 'bi':
        return SMapBurundiColors().toMap().keys.toList();

      case 'ca':
        return SMapCanadaColors().toMap().keys.toList();

      case 'cm':
        return SMapCameroonColors().toMap().keys.toList();

      case 'cf':
        return SMapCentralAfricanRepublicColors().toMap().keys.toList();

      case 'cv':
        return SMapCapeVerdeColors().toMap().keys.toList();

      case 'td':
        return SMapChadColors().toMap().keys.toList();

      case 'cn':
        return SMapChinaColors().toMap().keys.toList();

      case 'ch':
        return SMapSwitzerlandColors().toMap().keys.toList();

      case 'cd':
        return SMapCongoDRColors().toMap().keys.toList();

      case 'cg':
        return SMapCongoBrazzavilleColors().toMap().keys.toList();

      case 'co':
        return SMapColombiaColors().toMap().keys.toList();

      case 'cr':
        return SMapCostaRicaColors().toMap().keys.toList();

      case 'hr':
        return SMapCroatiaColors().toMap().keys.toList();

      case 'cu':
        return SMapCubaColors().toMap().keys.toList();

      case 'cl':
        return SMapChileColors().toMap().keys.toList();

      case 'ci':
        return SMapIvoryCoastColors().toMap().keys.toList();

      case 'cy':
        return SMapCyprusColors().toMap().keys.toList();

      case 'cz':
        return SMapCzechRepublicColors().toMap().keys.toList();

      case 'dk':
        return SMapDenmarkColors().toMap().keys.toList();

      case 'dj':
        return SMapDjiboutiColors().toMap().keys.toList();

      case 'do':
        return SMapDominicanRepublicColors().toMap().keys.toList();

      case 'ec':
        return SMapEcuadorColors().toMap().keys.toList();

      case 'es':
        return SMapSpainColors().toMap().keys.toList();

      case 'eg':
        return SMapEgyptColors().toMap().keys.toList();

      case 'et':
        return SMapEthiopiaColors().toMap().keys.toList();

      case 'sv':
        return SMapElSalvadorColors().toMap().keys.toList();

      case 'ee':
        return SMapEstoniaColors().toMap().keys.toList();

      case 'fo':
        return SMapFaroeIslandsColors().toMap().keys.toList();

      case 'fi':
        return SMapFinlandColors().toMap().keys.toList();

      case 'fr':
        return SMapFranceColors().toMap().keys.toList();

      case 'gb':
        return SMapUnitedKingdomColors().toMap().keys.toList();

      case 'ge':
        return SMapGeorgiaColors().toMap().keys.toList();

      case 'de':
        return SMapGermanyColors().toMap().keys.toList();

      case 'gr':
        return SMapGreeceColors().toMap().keys.toList();

      case 'gt':
        return SMapGuatemalaColors().toMap().keys.toList();

      case 'gn':
        return SMapGuineaColors().toMap().keys.toList();

      case 'hi':
        return SMapHaitiColors().toMap().keys.toList();

      case 'hk':
        return SMapHongKongColors().toMap().keys.toList();

      case 'hn':
        return SMapHondurasColors().toMap().keys.toList();

      case 'hu':
        return SMapHungaryColors().toMap().keys.toList();

      case 'in':
        return SMapIndiaColors().toMap().keys.toList();

      case 'id':
        return SMapIndonesiaColors().toMap().keys.toList();

      case 'il':
        return SMapIsraelColors().toMap().keys.toList();

      case 'ir':
        return SMapIranColors().toMap().keys.toList();

      case 'iq':
        return SMapIraqColors().toMap().keys.toList();

      case 'ie':
        return SMapIrelandColors().toMap().keys.toList();

      case 'it':
        return SMapItalyColors().toMap().keys.toList();

      case 'jm':
        return SMapJamaicaColors().toMap().keys.toList();

      case 'jp':
        return SMapJapanColors().toMap().keys.toList();

      case 'kz':
        return SMapKazakhstanColors().toMap().keys.toList();

      case 'ke':
        return SMapKenyaColors().toMap().keys.toList();

      case 'xk':
        return SMapKosovoColors().toMap().keys.toList();

      case 'kg':
        return SMapKyrgyzstanColors().toMap().keys.toList();

      case 'la':
        return SMapLaosColors().toMap().keys.toList();

      case 'lv':
        return SMapLatviaColors().toMap().keys.toList();

      case 'li':
        return SMapLiechtensteinColors().toMap().keys.toList();

      case 'lt':
        return SMapLithuaniaColors().toMap().keys.toList();

      case 'lu':
        return SMapLuxembourgColors().toMap().keys.toList();

      case 'mk':
        return SMapMacedoniaColors().toMap().keys.toList();

      case 'ml':
        return SMapMaliColors().toMap().keys.toList();

      case 'mt':
        return SMapMaltaColors().toMap().keys.toList();

      case 'mz':
        return SMapMozambiqueColors().toMap().keys.toList();

      case 'mx':
        return SMapMexicoColors().toMap().keys.toList();

      case 'md':
        return SMapMoldovaColors().toMap().keys.toList();

      case 'me':
        return SMapMontenegroColors().toMap().keys.toList();

      case 'ma':
        return SMapMoroccoColors().toMap().keys.toList();

      case 'mm':
        return SMapMyanmarColors().toMap().keys.toList();

      case 'my':
        return SMapMalaysiaColors().toMap().keys.toList();

      case 'na':
        return SMapNamibiaColors().toMap().keys.toList();

      case 'np':
        return SMapNepalColors().toMap().keys.toList();

      case 'nl':
        return SMapNetherlandsColors().toMap().keys.toList();

      case 'nz':
        return SMapNewZealandColors().toMap().keys.toList();

      case 'ni':
        return SMapNicaraguaColors().toMap().keys.toList();

      case 'ng':
        return SMapNigeriaColors().toMap().keys.toList();

      case 'no':
        return SMapNorwayColors().toMap().keys.toList();

      case 'om':
        return SMapOmanColors().toMap().keys.toList();

      case 'ps':
        return SMapPalestineColors().toMap().keys.toList();

      case 'pk':
        return SMapPakistanColors().toMap().keys.toList();

      case 'ph':
        return SMapPhilippinesColors().toMap().keys.toList();

      case 'pa':
        return SMapPanamaColors().toMap().keys.toList();

      case 'pe':
        return SMapPeruColors().toMap().keys.toList();

      case 'pr':
        return SMapPuertoRicoColors().toMap().keys.toList();

      case 'py':
        return SMapParaguayColors().toMap().keys.toList();

      case 'pl':
        return SMapPolandColors().toMap().keys.toList();

      case 'pt':
        return SMapPortugalColors().toMap().keys.toList();

      case 'qa':
        return SMapQatarColors().toMap().keys.toList();

      case 'ro':
        return SMapRomaniaColors().toMap().keys.toList();

      case 'ru':
        return SMapRussiaColors().toMap().keys.toList();

      case 'rw':
        return SMapRwandaColors().toMap().keys.toList();

      case 'sa':
        return SMapSaudiArabiaColors().toMap().keys.toList();

      case 'rs':
        return SMapSerbiaColors().toMap().keys.toList();

      case 'sd':
        return SMapSudanColors().toMap().keys.toList();

      case 'sg':
        return SMapSingaporeColors().toMap().keys.toList();

      case 'sl':
        return SMapSierraLeoneColors().toMap().keys.toList();

      case 'sk':
        return SMapSlovakiaColors().toMap().keys.toList();

      case 'si':
        return SMapSloveniaColors().toMap().keys.toList();

      case 'kr':
        return SMapSouthKoreaColors().toMap().keys.toList();

      case 'lk':
        return SMapSriLankaColors().toMap().keys.toList();

      case 'se':
        return SMapSwedenColors().toMap().keys.toList();

      case 'sy':
        return SMapSyriaColors().toMap().keys.toList();

      case 'tw':
        return SMapTaiwanColors().toMap().keys.toList();

      case 'tj':
        return SMapTajikistanColors().toMap().keys.toList();

      case 'th':
        return SMapThailandColors().toMap().keys.toList();

      case 'tr':
        return SMapTurkeyColors().toMap().keys.toList();

      case 'ug':
        return SMapUgandaColors().toMap().keys.toList();

      case 'ua':
        return SMapUkraineColors().toMap().keys.toList();

      case 'ae':
        return SMapUnitedArabEmiratesColors().toMap().keys.toList();

      case 'us':
        return SMapUnitedStatesColors().toMap().keys.toList();

      case 'uy':
        return SMapUruguayColors().toMap().keys.toList();

      case 'uz':
        return SMapUzbekistanColors().toMap().keys.toList();

      case 've':
        return SMapVenezuelaColors().toMap().keys.toList();

      case 'vn':
        return SMapVietnamColors().toMap().keys.toList();

      case 'ye':
        return SMapYemenColors().toMap().keys.toList();

      case 'za':
        return SMapSouthAfricaColors().toMap().keys.toList();

      case 'zm':
        return SMapZambiaColors().toMap().keys.toList();

      case 'zw':
        return SMapZimbabweColors().toMap().keys.toList();

      default:
        return [];
    }
  }

  static List<Map<String, dynamic>> getProperties(String input) {
    Map<String, dynamic> instructions = json.decode(input);

    List paths = instructions['i'];

    List<Map<String, dynamic>> properties = [];

    for (var element in paths) {
      properties.add({
        'name': element['n'],
        'id': element['u'],
        'color': null,
      });
    }

    return properties;
  }

  static MapCountryData initState(String country) {
    final instruction = getInstructions(country);
    final properties = getProperties(instruction);
    properties.sort((a, b) => a['name'].compareTo(b['name']));
    final Map<String, Color?> keyValuesPaires = {};
    for (var element in properties) {
      keyValuesPaires.addAll({element['id']: element['color']});
    }
    return MapCountryData(
        country: country,
        instruction: instruction,
        properties: properties,
        keyValuesPaires: keyValuesPaires);
    if (instruction != "NOT SUPPORTED") {
      final properties = getProperties(instruction);
      properties.sort((a, b) => a['name'].compareTo(b['name']));
      final Map<String, Color?> keyValuesPaires = {};
      for (var element in properties) {
        keyValuesPaires.addAll({element['id']: element['color']});
      }
      final thisMapData = MapCountryData(
          country: country,
          instruction: instruction,
          properties: properties,
          keyValuesPaires: keyValuesPaires);
      // state = thisMapData;
    } else {}
  }
}
