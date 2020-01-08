python3 <<EOF
import vim
from urllib import request
from urllib import parse
from bs4 import BeautifulSoup
import re

#判断输入是否为英文
English_chars = "abcdefghijklmnopqrstuvwxyz -'ABCDEFGHIJKLMNOPQRSTUVWXYZ"

def isenglish(words):
    return not False in [c in English_chars for c in words]

#英译汉
def youdao_en_to_ch(words):
    youdao_URL = 'http://dict.youdao.com/w/{0}/#keyfrom=dict2.top'.format(words)
    response = request.urlopen(youdao_URL)
    html = response.read().decode('utf-8')
    soup = BeautifulSoup(html, 'html5lib')    
    translate = {}
    pronounce_search = soup.find_all('span', class_ = 'pronounce')
    try:
        pronounce = {}
        for p in pronounce_search:
            p_key, p_value = p.stripped_strings
            pronounce[p_key] = p_value
        if pronounce is not {}:
            translate['pronounce'] = pronounce
    except Exception as error:
        pass
    
    mean_search = soup.find('div', class_='trans-container')
    if mean_search is not None:
        original_mean_search = mean_search.find_all('li')
        additional_mean_search = mean_search.find('p')
        original = []
        for li in original_mean_search:
            original.append(li.contents[0])
        translate['original'] = original
    try:
        additional = additional_mean_search.contents[0]
        additional = re.sub(r'(\[\n +)|(\n +\])|(\n +)', '\n', additional)
        translate['additional'] = additional[1:-1]
    except Exception as error:
        pass
    return translate

# 汉译英
def youdao_ch_to_en(words):
    urlwords = parse.urlencode({'':words})[1:]
    youdao_URL = 'http://dict.youdao.com/w/{0}/#keyfrom=dict2.top'.format(urlwords)
    response = request.urlopen(youdao_URL)
    html = response.read().decode('utf-8')
    soup = BeautifulSoup(html, 'html5lib')
    
    translate = {}
    wordGroups = soup.find_all('p', class_ = 'wordGroup')
    for wordgroup in wordGroups:
        wordtype = wordgroup.find('span')
        if wordtype is None:
            break
        elif isinstance(wordtype.contents[0], str):
            contentTitle = []
            content_search = wordgroup.find_all('a', class_ = 'search-js')
            for c in content_search:
                contentTitle.append(c.contents[0])
            translate[wordtype.contents[0]] = contentTitle
        else:
            contentTitle = []
            content_search = wordgroup.find_all('a')
            for c in content_search:
                if c['href'].endswith('E2Ctranslation'):
                    contentTitle.append(c.contents[0])
            if contentTitle != []:
                if 'other.' in translate.keys():
                    translate['other.'] += contentTitle
                else:
                    translate['other.'] = contentTitle
    return translate
    
    
# 打印英译汉结果
def print_en_to_ch(translate):
    if 'pronounce' in translate.keys():
        print('pronunciation:')
        for item in translate['pronounce'].items():
            print(item[0], item[1])
    if 'original' not in translate.keys():
        print('Fail to translate!')
        return
    print('meaning:')
    for li in translate['original']:
        print(li)
    if 'additional' in translate.keys():
        print('other:')
        print(translate['additional'])

# 打印汉译英结果
def print_ch_to_en(translate):
    for wordtype in translate.keys():
        print('{0} {1}'.format(wordtype, '; '.join(translate[wordtype])))

def translate(words):
    if(len(words) == 0):
        print("No input!")
        return
    try:
        if isenglish(words):
            translate = youdao_en_to_ch(words)
            print_en_to_ch(translate)
        else:
            translate = youdao_ch_to_en(words)
            print_ch_to_en(translate)
    except Exception as error:
        print(error)
EOF

function! trans#Mytranslate(words)
python3 << EOF
words = vim.eval("a:words")
translate(words)
EOF
endfunction

