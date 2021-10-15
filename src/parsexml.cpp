// [[Rcpp::plugins(cpp11)]]
// [[Rcpp::depends(RcppThread)]]
#define RCPPTHREAD_OVERRIDE_THREAD 1

#include <Rcpp.h>
#include <fstream>
#include "./rapidxml-1.13/rapidxml.hpp"
#include "./rapidxml-1.13/rapidxml_utils.hpp"

using namespace Rcpp;

//' Parse XML output of CaboCha
//' @param path String scalar.
//' @return data.frame.
//' @keywords internal
// [[Rcpp::export(rng = false)]]
DataFrame parse_xml(const std::string path) {

    std::ifstream file(R_ExpandFileName(path.c_str()), std::ios::in);
    if (!file) {
      throw std::runtime_error("Failed to open " + path + ". Check file path.");
    }
    rapidxml::xml_document<> doc;
    rapidxml::file<> input(file);

    doc.parse<rapidxml::parse_trim_whitespace>(input.data());

    rapidxml::xml_node<>* node = doc.first_node(); // root node

    std::vector< std::uint_fast32_t > sentence_id;
    std::vector< std::string > chunk_id;
    std::vector< std::string > token_id;
    std::vector< std::string > token;
    std::vector< std::string > chunk_link;
    std::vector< std::string > chunk_score;
    std::vector< std::string > chunk_head;
    std::vector< std::string > chunk_func;
    std::vector< std::string > token_feature;
    std::vector< std::string > token_entity;

    std::uint_fast32_t sentenceCount = 0;

    for ( rapidxml::xml_node<>* sentence = node->first_node("sentence");
          sentence != nullptr;
          sentence = sentence->next_sibling() ) {

        std::uint_fast32_t tokCount = 0;

        for ( rapidxml::xml_node<>* chunk = sentence->first_node("chunk");
              chunk != nullptr;
              chunk = chunk->next_sibling() ) {

            rapidxml::xml_attribute<> *cid = chunk->first_attribute("id");
            rapidxml::xml_attribute<> *link = chunk->first_attribute("link");
            rapidxml::xml_attribute<> *score = chunk->first_attribute("score");
            rapidxml::xml_attribute<> *head = chunk->first_attribute("head");
            rapidxml::xml_attribute<> *func = chunk->first_attribute("func");

            for ( rapidxml::xml_node<>* tok = chunk->first_node("tok");
                  tok != nullptr;
                  tok = tok->next_sibling() ){

                rapidxml::xml_attribute<> *tid = tok->first_attribute("id");
                rapidxml::xml_attribute<> *feature = tok->first_attribute("feature");
                rapidxml::xml_attribute<> *ne = tok->first_attribute("ne");

                sentence_id.push_back(sentenceCount);
                chunk_id.push_back(cid->value());
                token_id.push_back(tid->value());
                token.push_back(tok->value());
                chunk_link.push_back(link->value());
                chunk_score.push_back(score->value());
                chunk_head.push_back(head->value());
                chunk_func.push_back(func->value());
                token_feature.push_back(feature->value());
                token_entity.push_back(ne->value());

                tokCount++;
            }

        }
        // check user interrupt.
        if (sentenceCount % 1000 == 0) checkUserInterrupt();

        sentenceCount++;
    }

    return DataFrame::create(
        _["sentence_id"] = wrap(sentence_id),
        _["chunk_id"] = wrap(chunk_id),
        _["token_id"] = wrap(token_id),
        _["token"] = wrap(token),
        _["chunk_link"] = wrap(chunk_link),
        _["chunk_score"] = wrap(chunk_score),
        _["chunk_head"] = wrap(chunk_head),
        _["chunk_func"] = wrap(chunk_func),
        _["token_feature"] = wrap(token_feature),
        _["token_entity"] = wrap(token_entity),
        _["stringsAsFactors"] = false);
}
