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
    urlwords = words.replace(' ', '%20')
    youdao_URL = 'http://dict.youdao.com/w/{0}/#keyfrom=dict2.top'.format(urlwords)
    response = request.urlopen(youdao_URL)
    html = response.read().decode('utf-8')
    soup = BeautifulSoup(html, 'html5lib')
    
    translate = {}
    pronounce_search = soup.find_all('span', class_ = 'pronounce')
    try:
        pronounce = []
        for p in pronounce_search:
            p_item = list(p.stripped_strings)
            if len(p_item) >= 2:
                pronounce.append(' '.join(p_item))
        if pronounce != []:
            translate['pronounce'] = '; '.join(pronounce)
    except Exception as error:
        print(error)
    
    mean_search = soup.find('div', class_='trans-container')
    additional_mean_search = None
    if mean_search != None:
        normal_mean_search = mean_search.find_all('li')
        additional_mean_search = mean_search.find('p')
        normal_mean = [li.contents[0] for li in normal_mean_search]
        translate['normal'] = normal_mean
    try:
        if additional_mean_search != None:
            additional = additional_mean_search.contents[0]
            additional = re.sub(r'\[\n *', '', additional)
            additional = re.sub(r' *\n *]', '', additional)
            additional = re.split(r' *\n *', additional)
            additional = " ".join([v if i%2==0 else v+';' for i,v in enumerate(additional)])
            translate['addition'] = additional
    except Exception as error:
        print(error)
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
def print_en_to_ch(translate, settings):
    if settings['show_pronunciation'] and ('pronounce' in translate.keys()):
        print('pronunciation:')
        print(translate['pronounce'])
    if 'normal' not in translate.keys():
        print('Fail to translate!')
        return
    print('meaning:')
    for li in translate['normal']:
        print(li)
    if settings['show_addition'] and ('addition' in translate.keys()):
        print('addition:')
        print(translate['addition'])

# 打印汉译英结果
def print_ch_to_en(translate, settings):
    for wordtype in translate.keys():
        print('{0} {1}'.format(wordtype, '; '.join(translate[wordtype])))

def translate(words, settings):
    if(len(words) == 0):
        print("No input!")
        return
    try:
        if isenglish(words):
            translate = youdao_en_to_ch(words)
            print_en_to_ch(translate, settings)
        else:
            translate = youdao_ch_to_en(words)
            print_ch_to_en(translate, settings)
    except Exception as error:
        print(error)
EOF

function! trans#Mytranslate(words, settings) abort
python3 << EOF
words = vim.eval("a:words")
settings = vim.eval('a:settings')
settings['show_pronunciation'] = int(settings['show_pronunciation'])
settings['show_addition'] = int(settings['show_addition'])
translate(words, settings)
EOF
endfunction

