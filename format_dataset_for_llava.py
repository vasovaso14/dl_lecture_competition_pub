import json
from collections import Counter
import re

def process_text(text):
    # lowercase
    text = text.lower()

    # 数詞を数字に変換
    num_word_to_digit = {
        'zero': '0', 'one': '1', 'two': '2', 'three': '3', 'four': '4',
        'five': '5', 'six': '6', 'seven': '7', 'eight': '8', 'nine': '9',
        'ten': '10'
    }
    for word, digit in num_word_to_digit.items():
        text = text.replace(word, digit)

    # 小数点のピリオドを削除
    text = re.sub(r'(?<!\d)\.(?!\d)', '', text)

    # 冠詞の削除
    text = re.sub(r'\b(a|an|the)\b', '', text)

    # 短縮形のカンマの追加
    contractions = {
        "dont": "don't", "isnt": "isn't", "arent": "aren't", "wont": "won't",
        "cant": "can't", "wouldnt": "wouldn't", "couldnt": "couldn't",
        "its": "it's", "youre": "you're"
    }
    for contraction, correct in contractions.items():
        text = text.replace(contraction, correct)

    # 句読点をスペースに変換
    text = re.sub(r"[^\w\s':]", ' ', text)

    # 句読点をスペースに変換
    text = re.sub(r'\s+,', ',', text)

    # 連続するスペースを1つに変換
    text = re.sub(r'\s+', ' ', text).strip()

    return text

def get_most_frequent_answer(answers_list):
    counter = Counter(answers_list)
    most_frequent_answer = counter.most_common(1)[0][0]
    return most_frequent_answer

def format_train_json(data_path, output_path):
    json_open = open(data_path, "r")
    json_load = json.load(json_open)
    # Initialize list to hold all JSON data
    json_data_list = []

    for idx in range(len(json_load["image"])):
        image_id = json_load["image"][str(idx)].replace(".jpg", "")
        question = process_text(json_load["question"][str(idx)])
        answers = json_load["answers"][str(idx)]
        answers_list = [process_text(answer["answer"]) for answer in answers]
        mode_answer = get_most_frequent_answer(answers_list)

        # Structure for LLaVA JSON
        json_data = {
            "id": image_id,
            "image": f"{image_id}.jpg",
            "conversations": [
                {
                    "from": "human",
                    "value": "<image>\n" + question
                },
                {
                    "from": "gpt",
                    "value": mode_answer
                }
            ]
        }
        
        # Append to list
        json_data_list.append(json_data)

    # Save the JSON data list to a file
    with open(output_path, 'w') as json_file:
        json.dump(json_data_list, json_file, indent=4)

def format_valid_jsonl(data_path, output_path):
    with open(data_path, "r") as json_open:
        json_load = json.load(json_open)
    
    # jsonlファイルに書き込む
    with open(output_path, 'w') as jsonl_file:
        for idx in range(len(json_load["image"])):
            image_id = json_load["image"][str(idx)].replace(".jpg", "")
            question = process_text(json_load["question"][str(idx)])

            # LLaVA JSONの構造
            json_data = {
                        "question_id": image_id,
                        "image": f"{image_id}.jpg",
                        "text": question
            }
            
            # jsonl形式で1行ずつ書き込む
            jsonl_file.write(json.dumps(json_data) + '\n')

format_train_json("./data/train.json", "./data/train_for_llava.json")
format_valid_jsonl("./data/valid.json", "./data/valid_for_llava.jsonl")
