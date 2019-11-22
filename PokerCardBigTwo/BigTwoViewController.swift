//
//  BigTwoViewController.swift
//  PokerCardBigTwo
//
//  Created by Stanley Tseng on 2019/11/17.
//  Copyright © 2019 StanleyAppWorld. All rights reserved.
//
//  目前進度：現在是v1.0版，兩人輪流出牌的方式進行遊戲。（電腦自動出牌...目前能力還不足夠，未來再挑戰）
//  雙方的牌面大小...自動比較的功能尚未製作...然後計分和提示功能也尚未製作。
//  目前沒有做Auto Layout，只適用在iPhone 11 橫向介面。
//  最後小提醒...有時會閃退唷！Orz


import UIKit
import GameplayKit

class BigTwoViewController: UIViewController {
    
    @IBOutlet var playCardsButton: [UIButton]! // 玩家的底牌
    @IBOutlet var playerPlayingCards: [UIImageView]! // 玩家目前出的牌
    @IBOutlet var playingCardButton: UIButton! // 出牌按鍵
    @IBOutlet var promptButton: UIButton! // 提示按鍵
    @IBOutlet var reselectButton: UIButton! // 重選按鍵
    @IBOutlet var passButton: UIButton! // pass按鍵
    @IBOutlet var playerPass: UIImageView! // 玩家pass的圖片
    @IBOutlet var playerRemainingCardsNumber: UILabel! // 玩家剩餘牌數
    @IBOutlet var playerYouWin: UIImageView!
    @IBOutlet var playerYouLose: UIImageView!
    
    @IBOutlet var banker1CardsButton: [UIButton]! // 電腦1的底牌
    @IBOutlet var banker1PlayingCard: [UIImageView]! // 電腦1目前出的牌
    @IBOutlet var b1PlayingCardButton: UIButton! // b1出牌按鍵
    @IBOutlet var b1PromptButton: UIButton! // b1提示按鍵
    @IBOutlet var b1ReselectButton: UIButton! // b1重選按鍵
    @IBOutlet var b1PassButton: UIButton! // b1pass按鍵
    @IBOutlet var banker1Pass: UIImageView! // 電腦1的pass的圖片
    @IBOutlet var b1RemainingCardsNumber: UILabel! // 電腦1剩餘牌數
    @IBOutlet var b1YouWin: UIImageView!
    @IBOutlet var b1YouLose: UIImageView!
    
    @IBOutlet var banker1Cards: [UIImageView]! // 電腦1的底牌
    @IBOutlet var banker2Cards: [UIImageView]! // 電腦2的底牌
    @IBOutlet var banker3Cards: [UIImageView]! // 電腦3的底牌
    
    @IBOutlet var gameOver: UIImageView!
    @IBOutlet var playAgainView: UIButton!
    
    var ranks = ["1","2","3","4","5","6","7","8","9","10","11","12","13"]
    var suits = ["clubs","diamonds","hearts","spades"]
    var pokerImageName = ""
    var card:PokerCards?
    var cardArray = [PokerCards(Level: 1, Number: 1, PokerName: "clubs1", Suit: "clubs")]
    let distribution = GKShuffledDistribution(lowestValue: 0, highestValue: 51)
    var pCards:[PokerCards] = []
    var b3Cards:[PokerCards] = []
    var b1Cards:[PokerCards] = []
    var b2Cards:[PokerCards] = []
    var playerCard:PokerCards?
    var banker3Card:PokerCards?
    var banker1Card:PokerCards?
    var banker2Card:PokerCards?
    var sortPCards:[PokerCards] = []
    var sortB3Cards:[PokerCards] = []
    var sortB1Cards:[PokerCards] = []
    var sortB2Cards:[PokerCards] = []
    var forSortCard = [3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 1 ,2] // 設定成我們要的排序
    var gameExecution = false
    var playingCardSelected = false
    var playingCards = [Int]() // 玩家要出的牌，從選出的牌做紀錄。
    var b1PlayingCards = [Int]() // 電腦1要出的牌，從選出的牌做紀錄。
    var playingCardsShow:[PokerCards] = [] // 玩家出的牌做出牌規則判斷用
    var banker1PlayingCardsShow:[PokerCards] = [] // 電腦1出的牌做出牌規則判斷用
    var playerPlayingCardTemp:[PokerCards] = [] // 玩家出的牌暫存用
    var b1playingCardTemp:[PokerCards] = [] // 電腦1出的牌暫存用
    var canPlay = false
    var playerCardCount:Int = 0
    var b1CardCount:Int = 0
    var newCurrentlyExistingCards = false
    var nextPlayer = false // 判斷是否換下一個人出牌
    var highCard = false
    var onePair = false
    var threeOfAKind = false
    var straight = false
    var flush = false
    var fullHouse = false
    var fourOfAKind = false
    var straightFlush = false
    var playerIsPass = false
    var pFirstPlayer = false
    var b1FirstPlayer = false
    var tempCards:[PokerCards] = []
    var p1TempCards:[PokerCards] = []
    
    var playerChip = 1000 // 目前尚未製作計分相關功能
    var bet = 100 // 目前尚未製作計分相關功能
    
    func pokerFunc()-> [PokerCards] {
        for i in 0 ..< suits.count {
            for j in 0 ..< ranks.count {
                pokerImageName = suits[i] + ranks[j]
                card = PokerCards(Level: i+1 , Number: j+1 , PokerName: pokerImageName, Suit: suits[i] )
                if let card = card {
                    cardArray += [card]
                }
            }
        }
        cardArray.removeFirst()
        return cardArray
    }
    
    // 自動發牌
    func deal() {
        
        if playerChip >= bet{
            for _ in 0...12 {
                playerCard = cardArray[distribution.nextInt()]
                banker3Card = cardArray[distribution.nextInt()]
                banker1Card = cardArray[distribution.nextInt()]
                banker2Card = cardArray[distribution.nextInt()]
                
                pCards += [playerCard!]
                b3Cards += [banker3Card!]
                b1Cards += [banker1Card!]
                b2Cards += [banker2Card!]
            }
        }
    }
    
    // 自動排序
    func sort() {
        // 將玩家的牌面重新排序
        for n in 0...12 {   // 設定成我們要的排序
            for k in 0...3 {    // 花色
                for b in 0...12 {
                    let m = forSortCard[n]
                    if pCards[b].PokerName == suits[k] + "\(m)" {
                        sortPCards += [pCards[b]]
                    }
                }
            }
        }
        
        // 將電腦3的牌面重新排序
        for n in 0...12 {   // 設定成我們要的排序
            for k in 0...3 {    // 花色
                for b in 0...12 {
                    let m = forSortCard[n]
                    if b3Cards[b].PokerName == suits[k] + "\(m)" {
                        sortB3Cards += [b3Cards[b]]
                    }
                }
            }
        }
        
        // 將將電腦1的牌面重新排序
        for n in 0...12 {   // 設定成我們要的排序
            for k in 0...3 {    // 花色
                for b in 0...12 {
                    let m = forSortCard[n]
                    if b1Cards[b].PokerName == suits[k] + "\(m)" {
                        sortB1Cards += [b1Cards[b]]
                    }
                }
            }
        }
        
        // 將將電腦2的牌面重新排序
        for n in 0...12 {   // 設定成我們要的排序
            for k in 0...3 {    // 花色
                for b in 0...12 {
                    let m = forSortCard[n]
                    if b2Cards[b].PokerName == suits[k] + "\(m)" {
                        sortB2Cards += [b2Cards[b]]
                    }
                }
            }
        }
        
        // 將玩家與電腦排序後陣列顯示在畫面的牌面上
        for p in 0...12 {
            
            playCardsButton[p].setImage(UIImage(named: sortPCards[p].PokerName )?.withRenderingMode(.alwaysOriginal), for: .normal)
            banker1CardsButton[p].setImage(UIImage(named: sortB1Cards[p].PokerName )?.withRenderingMode(.alwaysOriginal), for: .normal)
            //            banker3Cards[p].image = UIImage(named: sortB3Cards[p].PokerName)
            //                        banker1Cards[p].image = UIImage(named: sortB1Cards[p].PokerName)
            //                        banker2Cards[p].image = UIImage(named: sortB2Cards[p].PokerName)
        }
    }
    
    // 玩家出牌規則
    func rulesOfPlaying (cardcount: Int) {
        
        // 一張（任何一張牌都可以出）
        if playerCardCount == 1 {
            
            canPlay = true
            highCard = true
            
            // 一對（2張一樣數字的牌都可以出）
        } else if playerCardCount == 2 && playingCardsShow[0].Number == playingCardsShow[1].Number {
            canPlay = true
            onePair = true
            
            // 三條（3張一樣數字的牌都可以出）
        } else if playerCardCount == 3 && playingCardsShow[0].Number == playingCardsShow[1].Number && playingCardsShow[0].Number == playingCardsShow[2].Number {
            canPlay = true
            threeOfAKind = true
            
            // 順子（5張有順序的牌都可以出）
        } else if playerCardCount == 5 && playingCardsShow[0].Number + 1 == playingCardsShow[1].Number && playingCardsShow[0].Number + 2 == playingCardsShow[2].Number && playingCardsShow[0].Number + 3 == playingCardsShow[3].Number && playingCardsShow[0].Number + 4 == playingCardsShow[4].Number || playerCardCount == 5 && playingCardsShow[0].Number + 1 == playingCardsShow[1].Number && playingCardsShow[0].Number + 2 == playingCardsShow[2].Number && playingCardsShow[0].Number + 3 == playingCardsShow[3].Number && playingCardsShow[0].Number - 9 == playingCardsShow[4].Number || playerCardCount == 5 && playingCardsShow[0].Number + 1 == playingCardsShow[1].Number && playingCardsShow[0].Number + 2 == playingCardsShow[2].Number && playingCardsShow[0].Number - 2 == playingCardsShow[3].Number && playingCardsShow[0].Number - 1 == playingCardsShow[4].Number || playerCardCount == 5 && playingCardsShow[0].Number + 1 == playingCardsShow[1].Number && playingCardsShow[0].Number + 2 == playingCardsShow[2].Number && playingCardsShow[0].Number + 3 == playingCardsShow[3].Number && playingCardsShow[0].Number - 1 == playingCardsShow[4].Number {
            
            if playingCardsShow[0].Number == 3 && playingCardsShow[1].Number == 4 && playingCardsShow[2].Number == 5 && playingCardsShow[3].Number == 1 && playingCardsShow[4].Number == 2 {
                tempCards = playingCardsShow
                tempCards[0] = playingCardsShow[3]
                tempCards[1] = playingCardsShow[4]
                tempCards[2] = playingCardsShow[0]
                tempCards[3] = playingCardsShow[1]
                tempCards[4] = playingCardsShow[2]
                playingCardsShow = tempCards
            } else if playingCardsShow[0].Number == 3 && playingCardsShow[1].Number == 4 && playingCardsShow[2].Number == 5 && playingCardsShow[3].Number == 6 && playingCardsShow[4].Number == 2 {
                tempCards = playingCardsShow
                tempCards[0] = playingCardsShow[4]
                tempCards[1] = playingCardsShow[0]
                tempCards[2] = playingCardsShow[1]
                tempCards[3] = playingCardsShow[2]
                tempCards[4] = playingCardsShow[3]
                playingCardsShow = tempCards
            }
            
            canPlay = true
            straight = true
            
            // 同花（5張同花色的牌都可以出）
        } else if playerCardCount == 5 && playingCardsShow[0].Suit == playingCardsShow[1].Suit && playingCardsShow[0].Suit == playingCardsShow[2].Suit && playingCardsShow[0].Suit == playingCardsShow[3].Suit && playingCardsShow[0].Suit == playingCardsShow[4].Suit{
            canPlay = true
            flush = true
            
            // 葫蘆（3張一樣加上2張一樣的牌都可以出）
        } else if playerCardCount == 5 && playingCardsShow[0].Number == playingCardsShow[1].Number && playingCardsShow[0].Number == playingCardsShow[2].Number && playingCardsShow[3].Number == playingCardsShow[4].Number || playerCardCount == 5 && playingCardsShow[0].Number == playingCardsShow[1].Number && playingCardsShow[2].Number == playingCardsShow[3].Number && playingCardsShow[2].Number == playingCardsShow[4].Number {
            canPlay = true
            fullHouse = true
            
            // 鐵支（4張一樣加上1張隨便的牌都可以出）
        } else if playerCardCount == 5 && playingCardsShow[0].Number == playingCardsShow[1].Number && playingCardsShow[0].Number == playingCardsShow[2].Number && playingCardsShow[0].Number == playingCardsShow[3].Number && playingCardsShow[0].Number != playingCardsShow[4].Number || playerCardCount == 5 && playingCardsShow[1].Number == playingCardsShow[2].Number && playingCardsShow[1].Number == playingCardsShow[3].Number && playingCardsShow[1].Number == playingCardsShow[4].Number && playingCardsShow[1].Number != playingCardsShow[0].Number {
            canPlay = true
            fourOfAKind = true
            
            // 同花順(5張同花色而且有順序的牌都可以出）
        } else if playerCardCount == 5 && playingCardsShow[0].Number + 1 == playingCardsShow[1].Number && playingCardsShow[0].Number + 2 == playingCardsShow[2].Number && playingCardsShow[0].Number + 3 == playingCardsShow[3].Number && playingCardsShow[0].Number + 4 == playingCardsShow[4].Number && playingCardsShow[0].Suit == playingCardsShow[1].Suit && playingCardsShow[0].Suit == playingCardsShow[2].Suit && playingCardsShow[0].Suit == playingCardsShow[3].Suit && playingCardsShow[0].Suit == playingCardsShow[4].Suit {
            canPlay = true
            straightFlush = true
            
        } else {
            canPlay = false
            playingCardsShow.removeAll()
            playingCards.removeAll()
        }
    }
    
    // 玩家進行出牌完後，更新手上現有的牌的函式
    func currentlyExistingCards () {
        
        b1PlayingCards = []
        banker1PlayingCardsShow = []
        for p in 0...playerPlayingCards.count-1 {
            playerPlayingCards[p].isHidden = false
        }
        
        for p in 0...4 {
            playerPlayingCards[p].image = UIImage(named: "")
        }
        
        if newCurrentlyExistingCards == true {
            
            // 將原本的牌面Button圖案刪除
            for p in 0...sortPCards.count-1 {
                
                playCardsButton[p].setImage(UIImage(named: "" )?.withRenderingMode(.alwaysOriginal), for: .normal)
            }
            print(sortPCards)
            // 將出掉的牌移除在現有牌面上。
            var n = 0
            for d in 0...playingCards.count-1 {
                sortPCards.remove(at: Int(playingCards[d] - n))
                n += 1
            }
            
            playerPlayingCardTemp = sortPCards
            
            if sortPCards.count == 0 {
                ScoreCalculation()
            } else {
                
                // 將自己的牌面改為最新牌面 (出第二次牌時位置應該會有錯！之後調整！）
                for z in 0...playerPlayingCardTemp.count-1 {
                    playCardsButton[z].setImage(UIImage(named: playerPlayingCardTemp[z].PokerName )?.withRenderingMode(.alwaysOriginal), for: .normal)
                    
                    // 設定出完牌後，牌面回到原本最底下水平位置及位移
                    playCardsButton[z].frame.origin = CGPoint(x: 170 + z*40, y: 282)

                }
                
                // 設定玩家出的牌，不同張數有不同的位移
                for p in 0...playingCardsShow.count-1 {
                    
                    playerPlayingCards[p].image = UIImage(named: playingCardsShow[p].PokerName)
                    playerPlayingCards[p].frame.origin = CGPoint(x: 610 + p*40, y: 282)
                    
                }
            }
        }
    }
    
    // 換其他玩家出牌
    
    // 電腦1出牌規則（用電腦1的代號）
    func b1RulesOfPlaying (cardcount: Int) {
        
        // 一張（任何一張牌都可以出）
        if b1CardCount == 1 {
            
            canPlay = true
            highCard = true
            
            // 一對（2張一樣數字的牌都可以出）
        } else if b1CardCount == 2 && banker1PlayingCardsShow[0].Number == banker1PlayingCardsShow[1].Number {
            canPlay = true
            onePair = true
            
            // 三條（3張一樣數字的牌都可以出）
        } else if b1CardCount == 3 && banker1PlayingCardsShow[0].Number == banker1PlayingCardsShow[1].Number && banker1PlayingCardsShow[0].Number == banker1PlayingCardsShow[2].Number {
            canPlay = true
            threeOfAKind = true
            
            // 順子（5張有順序的牌都可以出）
        } else if b1CardCount == 5 && banker1PlayingCardsShow[0].Number + 1 == banker1PlayingCardsShow[1].Number && banker1PlayingCardsShow[0].Number + 2 == banker1PlayingCardsShow[2].Number && banker1PlayingCardsShow[0].Number + 3 == banker1PlayingCardsShow[3].Number && banker1PlayingCardsShow[0].Number + 4 == banker1PlayingCardsShow[4].Number || b1CardCount == 5 && banker1PlayingCardsShow[0].Number + 1 == banker1PlayingCardsShow[1].Number && banker1PlayingCardsShow[0].Number + 2 == banker1PlayingCardsShow[2].Number && banker1PlayingCardsShow[0].Number + 3 == banker1PlayingCardsShow[3].Number && banker1PlayingCardsShow[0].Number - 9 == banker1PlayingCardsShow[4].Number || b1CardCount == 5 && banker1PlayingCardsShow[0].Number + 1 == banker1PlayingCardsShow[1].Number && banker1PlayingCardsShow[0].Number + 2 == banker1PlayingCardsShow[2].Number && banker1PlayingCardsShow[0].Number - 2 == banker1PlayingCardsShow[3].Number && banker1PlayingCardsShow[0].Number - 1 == banker1PlayingCardsShow[4].Number || b1CardCount == 5 && banker1PlayingCardsShow[0].Number + 1 == banker1PlayingCardsShow[1].Number && banker1PlayingCardsShow[0].Number + 2 == banker1PlayingCardsShow[2].Number && banker1PlayingCardsShow[0].Number + 3 == banker1PlayingCardsShow[3].Number && banker1PlayingCardsShow[0].Number - 1 == banker1PlayingCardsShow[4].Number {
            
            if banker1PlayingCardsShow[0].Number == 3 && banker1PlayingCardsShow[1].Number == 4 && banker1PlayingCardsShow[2].Number == 5 && banker1PlayingCardsShow[3].Number == 1 && banker1PlayingCardsShow[4].Number == 2 {
                p1TempCards = banker1PlayingCardsShow
                p1TempCards[0] = banker1PlayingCardsShow[3]
                p1TempCards[1] = banker1PlayingCardsShow[4]
                p1TempCards[2] = banker1PlayingCardsShow[0]
                p1TempCards[3] = banker1PlayingCardsShow[1]
                p1TempCards[4] = banker1PlayingCardsShow[2]
                banker1PlayingCardsShow = p1TempCards
            } else if banker1PlayingCardsShow[0].Number == 3 && banker1PlayingCardsShow[1].Number == 4 && banker1PlayingCardsShow[2].Number == 5 && banker1PlayingCardsShow[3].Number == 6 && banker1PlayingCardsShow[4].Number == 2 {
                p1TempCards = banker1PlayingCardsShow
                p1TempCards[0] = banker1PlayingCardsShow[4]
                p1TempCards[1] = banker1PlayingCardsShow[0]
                p1TempCards[2] = banker1PlayingCardsShow[1]
                p1TempCards[3] = banker1PlayingCardsShow[2]
                p1TempCards[4] = banker1PlayingCardsShow[3]
                banker1PlayingCardsShow = p1TempCards
            }
            
            canPlay = true
            straight = true
            
            // 同花（5張同花色的牌都可以出）
        } else if b1CardCount == 5 && banker1PlayingCardsShow[0].Suit == banker1PlayingCardsShow[1].Suit && banker1PlayingCardsShow[0].Suit == banker1PlayingCardsShow[2].Suit && banker1PlayingCardsShow[0].Suit == banker1PlayingCardsShow[3].Suit && banker1PlayingCardsShow[0].Suit == banker1PlayingCardsShow[4].Suit{
            canPlay = true
            flush = true
            
            // 葫蘆（3張一樣加上2張一樣的牌都可以出）
        } else if b1CardCount == 5 && banker1PlayingCardsShow[0].Number == banker1PlayingCardsShow[1].Number && banker1PlayingCardsShow[0].Number == banker1PlayingCardsShow[2].Number && banker1PlayingCardsShow[3].Number == banker1PlayingCardsShow[4].Number || playerCardCount == 5 && banker1PlayingCardsShow[0].Number == banker1PlayingCardsShow[1].Number && banker1PlayingCardsShow[2].Number == banker1PlayingCardsShow[3].Number && banker1PlayingCardsShow[2].Number == banker1PlayingCardsShow[4].Number {
            canPlay = true
            fullHouse = true
            
            // 鐵支（4張一樣加上1張隨便的牌都可以出）
        } else if b1CardCount == 5 && banker1PlayingCardsShow[0].Number == banker1PlayingCardsShow[1].Number && banker1PlayingCardsShow[0].Number == banker1PlayingCardsShow[2].Number && banker1PlayingCardsShow[0].Number == banker1PlayingCardsShow[3].Number && banker1PlayingCardsShow[0].Number != banker1PlayingCardsShow[4].Number || b1CardCount == 5 && banker1PlayingCardsShow[1].Number == banker1PlayingCardsShow[2].Number && banker1PlayingCardsShow[1].Number == banker1PlayingCardsShow[3].Number && banker1PlayingCardsShow[1].Number == banker1PlayingCardsShow[4].Number && banker1PlayingCardsShow[1].Number != banker1PlayingCardsShow[0].Number {
            canPlay = true
            fourOfAKind = true
            
            // 同花順(5張同花色而且有順序的牌都可以出）
        } else if b1CardCount == 5 && banker1PlayingCardsShow[0].Number + 1 == banker1PlayingCardsShow[1].Number && banker1PlayingCardsShow[0].Number + 2 == banker1PlayingCardsShow[2].Number && banker1PlayingCardsShow[0].Number + 3 == banker1PlayingCardsShow[3].Number && banker1PlayingCardsShow[0].Number + 4 == banker1PlayingCardsShow[4].Number && banker1PlayingCardsShow[0].Suit == banker1PlayingCardsShow[1].Suit && banker1PlayingCardsShow[0].Suit == banker1PlayingCardsShow[2].Suit && banker1PlayingCardsShow[0].Suit == banker1PlayingCardsShow[3].Suit && banker1PlayingCardsShow[0].Suit == banker1PlayingCardsShow[4].Suit {
            canPlay = true
            straightFlush = true
            
        } else {
            canPlay = false
            banker1PlayingCardsShow.removeAll()
            playingCards.removeAll()
        }
    }
    
    // 電腦1出牌完後，更新手上現有的牌的函式
    func b1CurrentlyExistingCards () {
        
        playingCards = []
        playingCardsShow = []
        
        for p in 0...banker1PlayingCard.count-1 {
            banker1PlayingCard[p].isHidden = false
        }
        
        for p in 0...4 {
            banker1PlayingCard[p].image = UIImage(named: "")
        }
        
        if newCurrentlyExistingCards == true {
            
            // 將原本的牌面Button圖案刪除
            for p in 0...sortB1Cards.count-1 {
                
                banker1CardsButton[p].setImage(UIImage(named: "" )?.withRenderingMode(.alwaysOriginal), for: .normal)
            }
            print(sortB1Cards)
            // 將出掉的牌移除在現有牌面上。
            var n = 0
            for d in 0...b1PlayingCards.count-1 {
                sortB1Cards.remove(at: Int(b1PlayingCards[d] - n))
                n += 1
            }
            
            b1playingCardTemp = sortB1Cards
            print(b1PlayingCards)
            print(sortB1Cards)
            
            if sortB1Cards.count == 0 {
                ScoreCalculation()
            } else {
                
                // 將自己的牌面改為最新牌面
                for z in 0...b1playingCardTemp.count-1 {
                    banker1CardsButton[z].setImage(UIImage(named: b1playingCardTemp[z].PokerName )?.withRenderingMode(.alwaysOriginal), for: .normal)
                    
                    // 設定出完牌後，牌面回到原本最底下水平位置及位移
                    banker1CardsButton[z].frame.origin = CGPoint(x: 170 + z*40, y: 90)
                }
                
                print(b1playingCardTemp.count)
                print(b1playingCardTemp)
                
                // 設定電腦1出的牌，不同張數有不同的位移
                for p in 0...banker1PlayingCardsShow.count-1 {
                    banker1PlayingCard[p].image = UIImage(named: banker1PlayingCardsShow[p].PokerName)
                    banker1PlayingCard[p].frame.origin = CGPoint(x: 610 + p*40, y: 90)
                }
            }
        }
    }
    
    // 顯示玩家相關按鍵
    func totalPlayerButtonOn () {
        playingCardButton.isHidden = false
        promptButton.isHidden = false
        reselectButton.isHidden = false
        passButton.isHidden = false
    }
    
    // 隱藏玩家相關按鍵
    func totalPlayerButtonOff () {
        playingCardButton.isHidden = true
        promptButton.isHidden = true
        reselectButton.isHidden = true
        passButton.isHidden = true
    }
    
    // 顯示電腦1相關按鍵
    func totalb1ButtonOn () {
        b1PlayingCardButton.isHidden = false
        b1PromptButton.isHidden = false
        b1ReselectButton.isHidden = false
        b1PassButton.isHidden = false
    }
    
    // 隱藏電腦1相關按鍵
    func totalb1ButtonOff () {
        b1PlayingCardButton.isHidden = true
        b1PromptButton.isHidden = true
        b1ReselectButton.isHidden = true
        b1PassButton.isHidden = true
    }
    
    // 誰是第一手
    func whoIsFirstPlayer () {
        
        if sortPCards[0].Number >= sortB1Cards[0].Number && sortPCards[0].Level > sortB1Cards[0].Level && sortPCards[0].Number == 3 || sortPCards[0].Number == 4 || sortPCards[0].Number == 5 {
            b1FirstPlayer = true
        } else {
            pFirstPlayer = true
        }
    }
    
    // 遊戲結束
    func ScoreCalculation () {
        gameOver.isHidden = false
        playAgainView.isHidden = false
        totalPlayerButtonOff()
        totalb1ButtonOff()
        
        if sortPCards.count == 0 {
            playerYouWin.isHidden = false
            b1YouLose.isHidden = false
        } else {
            playerYouLose.isHidden = false
            b1YouWin.isHidden = false
        }
    }
    
    // viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cardArray = pokerFunc()
        deal()
        sort()
        whoIsFirstPlayer()
        gameExecution = true
        playerPass.isHidden = true
        banker1Pass.isHidden = true
        gameOver.isHidden = true
        playerYouWin.isHidden = true
        playerYouLose.isHidden = true
        b1YouWin.isHidden = true
        b1YouLose.isHidden = true
        playAgainView.isHidden = true
    }
    
    // 設定玩家選牌功能
    @IBAction func playerCardsButton(_ sender: UIButton) {
        
        gameExecution = true
        let pCardBtnNum = sender.tag
        
        if playCardsButton[pCardBtnNum].frame.origin == CGPoint(x: 170 + pCardBtnNum*40, y: 265) {
            playCardsButton[pCardBtnNum].frame.origin = CGPoint(x: 170 + pCardBtnNum*40, y: 282)
        } else {
            playCardsButton[pCardBtnNum].frame.origin = CGPoint(x: 170 + pCardBtnNum*40, y: 265)
        }
    }
    
    // 玩家出牌與相關設定
    @IBAction func playingCard(_ sender: Any) {
        
        if nextPlayer == true || pFirstPlayer == true  {
            if sortPCards.count == 0 {
                ScoreCalculation()
                
            } else {
                
                // 點選出牌按鈕後，將選好的牌存在陣列中
                for i in 0...sortPCards.count-1 {
                    if playCardsButton[i].frame.origin == CGPoint(x: 170 + i*40, y: 265) {
                        playingCards += [i]
                    }
                }
                
                // 把要出的牌秀出來
                for n in 0...playingCards.count-1 {
                    playingCardsShow += [sortPCards[playingCards[n]]]
                }
                
                newCurrentlyExistingCards = true
                
                // 在進入出牌規則前做判斷
                if newCurrentlyExistingCards == true {
                    playingCardSelected = true
                    
                    // 設定出牌數字，呼叫出牌規則函式進行判斷
                    playerCardCount = playingCards.count
                    rulesOfPlaying(cardcount: playerCardCount)
                    
                } else {
                    playingCardSelected = false
                    playingCards.removeAll()
                }
                
                // 設定條件成立，出牌按鈕才能正常動作
                if playingCardSelected == true && canPlay == true {
                    totalPlayerButtonOff()
                    totalb1ButtonOn()
                    currentlyExistingCards() // 進行出牌完後，更新手上現有的牌的函式
                    nextPlayer = true
                    banker1Pass.isHidden = true
                    playerRemainingCardsNumber.text = "\(sortPCards.count)"
                } else {
                    nextPlayer = false
                }
                
                if sortPCards.count == 0 {
                    ScoreCalculation()
                    
                } else {
                    
                    for z in 0...sortPCards.count-1 {
                        playCardsButton[z].isHidden = true
                    }
                    for z in 0...sortB1Cards.count-1 {
                        banker1CardsButton[z].isHidden = false
                    }
                    for y in 0...banker1PlayingCard.count-1 {
                        banker1PlayingCard[y].isHidden = true
                    }
                }
            }
        }
    }
    
    @IBAction func prompt(_ sender: Any) {
        
    }
    
    @IBAction func reselect(_ sender: Any) {
        for p in 0...sortPCards.count-1 {
            if playCardsButton[p].frame.origin == CGPoint(x: 170 + p*40, y: 265) {
                playCardsButton[p].frame.origin = CGPoint(x: 170 + p*40, y: 282)
            }
        }
    }
    
    // 玩家的pass按鍵
    @IBAction func pass(_ sender: Any) {
        
        if nextPlayer == true {
            canPlay = true
            playerIsPass = true
            playerPass.isHidden = false
            totalb1ButtonOn()
            totalPlayerButtonOff()
            b1PlayingCards = []
            banker1PlayingCardsShow = []
            
            
            for z in 0...sortPCards.count-1 {
                playCardsButton[z].isHidden = true
            }
            for z in 0...sortB1Cards.count-1 {
                banker1CardsButton[z].isHidden = false
            }
            for p in 0...playerPlayingCards.count-1 {
                playerPlayingCards[p].isHidden = true
            }
            for p in 0...banker1PlayingCard.count-1 {
                banker1PlayingCard[p].isHidden = true
            }
        }
    }
    
    // 設定電腦1選牌功能
    @IBAction func p1CardButton(_ sender: UIButton) {
        
        gameExecution = true
        let b1CardBtnNum = sender.tag
        
        if banker1CardsButton[b1CardBtnNum].frame.origin == CGPoint(x: 170 + b1CardBtnNum*40, y: 90) {
            banker1CardsButton[b1CardBtnNum].frame.origin = CGPoint(x: 170 + b1CardBtnNum*40, y: 73)
        } else {
            banker1CardsButton[b1CardBtnNum].frame.origin = CGPoint(x: 170 + b1CardBtnNum*40, y: 90)
        }
    }
    
    // 電腦1出牌與相關設定
    @IBAction func b1PlayingCard(_ sender: Any) {
        
        if  nextPlayer == true || b1FirstPlayer == true {
            
            if sortB1Cards.count == 0 {
                ScoreCalculation()
            } else {
                
                // 點選出牌按鈕後，將選好的牌存在陣列中
                for i in 0...sortB1Cards.count-1 {
                    if banker1CardsButton[i].frame.origin == CGPoint(x: 170 + i*40, y: 73) {
                        b1PlayingCards += [i]
                    }
                }
                
                // 把要出的牌秀出來
                for n in 0...b1PlayingCards.count-1 {
                    banker1PlayingCardsShow += [sortB1Cards[b1PlayingCards[n]]]
                }
                
                newCurrentlyExistingCards = true
                
                // 在進入出牌規則前做判斷
                if newCurrentlyExistingCards == true {
                    playingCardSelected = true
                    
                    // 設定出牌數字，呼叫出牌規則函式進行判斷
                    b1CardCount = b1PlayingCards.count
                    b1RulesOfPlaying(cardcount: b1CardCount)
                    
                    print(b1CardCount)
                    print(banker1PlayingCardsShow)
                    print(sortB1Cards)
                    print(sortB1Cards.count)
                    
                } else {
                    playingCardSelected = false
                    b1PlayingCards.removeAll()
                }
                
                // 設定條件成立，出牌按鈕才能正常動作
                if playingCardSelected == true && canPlay == true {
                    totalPlayerButtonOn()
                    totalb1ButtonOff()
                    b1CurrentlyExistingCards() // 進行出牌完後，更新手上現有的牌的函式
                    nextPlayer = true
                    playerPass.isHidden = true
                    b1RemainingCardsNumber.text = "\(sortB1Cards.count)"
                } else {
                    nextPlayer = false
                }
                
                if sortB1Cards.count == 0 {
                    ScoreCalculation()
                    
                } else {
                    
                    for z in 0...sortB1Cards.count-1 {
                        banker1CardsButton[z].isHidden = true
                    }
                    for z in 0...sortPCards.count-1 {
                        playCardsButton[z].isHidden = false
                    }
                    for y in 0...playerPlayingCards.count-1 {
                        playerPlayingCards[y].isHidden = true
                    }
                }
            }
        }
    }
    
    @IBAction func b1Prompt(_ sender: Any) {
    }
    
    
    @IBAction func b1Reselect(_ sender: Any) {
        for b in 0...sortB1Cards.count-1 {
            if banker1CardsButton[b].frame.origin == CGPoint(x: 170 + b*40, y: 265) {
                banker1CardsButton[b].frame.origin = CGPoint(x: 170 + b*40, y: 282)
            }
        }
    }
    
    // 電腦1的pass按鍵
    @IBAction func b1Pass(_ sender: Any) {
        if nextPlayer == true {
            canPlay = true
            playerIsPass = true
            banker1Pass.isHidden = false
            totalb1ButtonOff()
            totalPlayerButtonOn()
            playingCards = []
            playingCardsShow = []
            
            for z in 0...sortB1Cards.count-1 {
                banker1CardsButton[z].isHidden = true
            }
            for z in 0...sortPCards.count-1 {
                playCardsButton[z].isHidden = false
            }
            for p in 0...banker1PlayingCard.count-1 {
                banker1PlayingCard[p].isHidden = true
            }
            for p in 0...playerPlayingCards.count-1 {
                playerPlayingCards[p].isHidden = true
            }
        }
    }
    
    @IBAction func playAgain(_ sender: Any) {
        
    }
}
