import requests
from wolfsoftware.pushover import Pushover
import time
import datetime

zipcode = os.environ.get('ZIPCODE') or '77084'
app_key = os.environ.get('PUSHOVER_APP_KEY')
user_key = os.environ.get('PUSHOVER_USER_KEY')
# Function to check the target URL
def check_target(url):
    headers = {
        'Accept': 'application/json',
        'Accept-Encoding': 'gzip, deflate, br, zstd',
        'Accept-Language': 'en-US,en;q=0.9',
        'Referrer': 'https://www.target.com/p/onyx-storm-target-exclusive-edition-by-rebecca-yarros-hardcover/-/A-93038252',
        'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/132.0.0.0 Safari/537.36 Edg/132.0.0.0'
        }
    # headers = {
    #     'Accept': 'application/json'
    #     }
    resp: requests.Response = requests.get(url, headers=headers)
    if resp.status_code != 200:
        print(f'Status is {resp.status_code}')
        return False, ''
    try:
        data = resp.json()
    except ValueError:
        print('Response content is not valid JSON')
        return False, ''
    test = data['data']['fulfillment_fiats']['locations']
    if(len(test) == 0):
        return False, ''
    final = []
    for l in test:
        final.append(l['store']['location_name'])
    
    return True, f'{len(test)} locations found: {str.join(', ', final)}'

# Function to send a text message using Twilio
def send_pushover_notification(message: str):
    if not app_key or not user_key:
        print('App key or user key is missing')
        print('Please set the environment variables PUSHOVER_APP_KEY and PUSHOVER_USER_KEY')
        print(message)
        return
    pushover = Pushover(user_key=user_key, api_token=app_key)
    pushover.send_message(message= message, title='Onyx Storm Available')
# Main function
def main():

    url = f'https://redsky.target.com/redsky_aggregations/v1/web/fiats_v1?key=9f36aeafbe60771e321a7cc95a78140772ab3e96&tcin=93038252&nearby={zipcode}&radius=10&limit=20&include_only_available_stores=true&requested_quantity=1&visitor_id=0194C9672B710201BDC3F7F947AD2674&channel=WEB&page=%2Fp%2FA-93038252'
    while True:
        curTime = datetime.datetime.now(datetime.UTC).strftime('%Y-%m-%d %H:%M:%S')
        inStock, message = check_target(url)
        if inStock:
            send_pushover_notification(message)
            print(f'{curTime} In stock!')
            break
        else:
            print(f'{curTime} Not in stock')
            time.sleep(60)

if __name__ == "__main__":
    main()