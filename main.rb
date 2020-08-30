require "selenium-webdriver"

# 環境準備手順
# https://qiita.com/meguroman/items/41ca17e7dc66d6c88c07
# https://intoli.com/blog/running-selenium-with-headless-chrome-in-ruby/

# selenium-webdriver ドキュメント
# https://www.rubydoc.info/gems/selenium-webdriver/Selenium/WebDriver/PointerActions

# 設定
target_url = ARGV[0]
target_page = ARGV[1].to_i
target_count = ARGV[2].to_i
puts "対象URL " + target_url
puts "対象ページ " + target_page.to_s
puts "対象件数 " + target_count.to_s

# selenium-webdriverの設定
ua = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/75.0.3764.0 Safari/537.36"

options = Selenium::WebDriver::Chrome::Options.new
options.add_argument('--headless')
options.add_argument("--user-agent=#{ua}")
driver = Selenium::WebDriver.for :chrome, options: options
driver.manage.timeouts.implicit_wait = 30

# ファイルダウンロードを許可する
# https://katsulog.tech/download_files_with_chromedrivers_headless_mode/
# https://qiita.com/sho7650/items/8fe07126f00c8e94e13b
# ダウンロード先のフォルダを設定
bridge = driver.send(:bridge)
path = "/session/#{bridge.session_id}/chromium/send_command"
command_hash = {
 cmd: 'Page.setDownloadBehavior',
 params: {
  behavior: 'allow',
  downloadPath: "/vagrant/projects/photo_fushime/downloads"
 }
}
bridge.http.call(:post, path, command_hash)


# フォトのトップページ
driver.navigate.to target_url
driver.manage.window.resize_to(800, 800)

# 個別アルバムに移動(0から始まる配列で番号指定)
driver.find_elements(:class,'jss71')[target_page - 1].click
sleep(10)
driver.save_screenshot "screenshot_album.png"

# あらかじめアルバムの先読みを行う
# 写真量によって調整
for num in 1..16 do
  driver.execute_script('window.scroll(0,90000);')
  sleep(5)
end
# 確認してスクロールを元に戻す
driver.save_screenshot "screenshot_buttom.png"
driver.execute_script('window.scroll(0,10);')
sleep(1)

# 確認
driver.save_screenshot "screenshot_list.png"

# 写真個別ページに入る
driver.find_element(:class,'jss137').click
sleep(7)

# 保存とページ送り
# 写真枚数分繰り返す
for num in 1..target_count do
  print("num = ", num, "\n")
  # 右上のダウンロードボタンを押す
  driver.action.move_to_location(760, 20).perform
  sleep(0.2)
  driver.action.click.perform
  sleep(2.8)
  # ページ送り
  driver.action.move_to_location(740, 420).perform
  sleep(0.2)
  driver.action.click.perform
  sleep(0.8)
end


# print(driver.current_url)

# 確認
driver.save_screenshot "screenshot_end.png"
# File.open("preview.html", mode = "w"){|f|
#   f.write(driver.page_source)
# }


