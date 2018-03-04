//
//  NewsViewController.swift
//  WePeiYang
//
//  Created by Allen X on 5/11/17.
//  Copyright © 2017 twtstudio. All rights reserved.
//

import UIKit
import MJRefresh


// FIXME: - 使用Tableview为容器，在tableviewCell上添加collectionView并做到高度自适应
class NewsViewController: UIViewController {
    var homepage: HomePageTopModel?
    var galleryList: [GalleryModel] = []
    var newsList: [NewsModel] = []
    var category = 1
    var page = 1

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }

//    fileprivate var backgroundScrollView: UIScrollView!
    fileprivate var newsHeaderView: NewsHeaderView!
    fileprivate var tableView: UITableView!
    fileprivate var bannerFooView: UIView!
//    var refreshHeader: MJRefreshHeader!
//    var refreshFooter: MJRefreshFooter!
    // iPhone X statusBarHeight

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        navigationController?.navigationBar.barStyle = .black
//        navigationController?.navigationBar.barTintColor = Metadata.Color.WPYAccentColor
        //Changing NavigationBar Title color
//        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: Metadata.Color.naviTextColor]
        // This is for removing the dark shadows when transitioning
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.isNavigationBarHidden = true
        navigationItem.title = "资讯"
        view.backgroundColor = .white
        setupUI()
        setupData()
    }
    
    func setupData() {
        CacheManager.retreive("news/homepage.json", from: .caches, as: HomePageTopModel.self, success: { homepage in
            self.homepage = homepage
            self.tableView.reloadData()
        }, failure: {
            HomePageHelper.getHomepage(success: { homepage in
                self.homepage = homepage
                self.tableView.reloadData()
            }, failure: { error in

            })
        })

        CacheManager.retreive("news/galleries.json", from: .caches, as: [GalleryModel].self, success: {  galleries in
            self.galleryList = galleries
            self.tableView.reloadData()
        }, failure: {
            HomePageHelper.getGallery(success: { galleries in
                self.galleryList = galleries
                self.tableView.reloadData()

            }, failure: { error in

            })
        })

        CacheManager.retreive("news/news.json", from: .caches, as: NewsTopModel.self, success: {  newsList in
            self.newsList = newsList.data
            self.tableView.reloadData()
        }, failure: {
            HomePageHelper.getNews(page: self.page, category: self.category, success: { newsList in
                self.newsList = newsList.data
                self.tableView.reloadData()
            }, failure: { error in

            })
        })
    }
    
    func setupUI() {
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        //MARK: - init scrollView
//        self.backgroundScrollView = UIScrollView(frame: UIScreen.main.bounds)
        //如果不设置contentsize label就无法变大小
//        self.backgroundScrollView.contentSize = CGSize(width: deviceWidth, height: deviceHeight)
        // -statusBarHeight 用来挡住RefreshHeader
//        self.backgroundScrollView.contentInset = UIEdgeInsetsMake(-statusBarHeight, 0, 0, 0)
//        backgroundScrollView.showsVerticalScrollIndicator = false
//        backgroundScrollView.showsHorizontalScrollIndicator = false
//        backgroundScrollView.backgroundColor = .white
//        backgroundScrollView.delegate = self
//        self.view.addSubview(backgroundScrollView)

        let statusBarHeight: CGFloat = UIScreen.main.bounds.height == 812 ? 44 : 20
        let tabBarHeight = self.tabBarController?.tabBar.height ?? 0
        // MARK: - init TableView
        tableView = UITableView(frame: CGRect(x: 0, y: statusBarHeight, width: deviceWidth, height: deviceHeight-statusBarHeight-tabBarHeight), style: .grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        // FIXME: 自适应UITableViewCell高度
        tableView.estimatedRowHeight = 500
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.showsVerticalScrollIndicator = false
//        tableView.allowsSelection = false
        tableView.backgroundColor = .white
        self.view.addSubview(tableView)
//        self.backgroundScrollView.addSubview(tableView)

        newsHeaderView = NewsHeaderView(withTitle: "News")
        
        // init refresh

        let header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(headerRefresh))
        let footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: #selector(footerLoadMore))
        
        tableView.mj_header = header
        tableView.mj_footer = footer

//        let refreshFooter = MJRefreshAutoNormalFooter()
//        tableView.mj_footer = refreshFooter
//
//        refreshHeader.setRefreshingTarget(self, refreshingAction: #selector(headerRefresh))
//        refreshFooter.setRefreshingTarget(self, refreshingAction: #selector(footerLoadMore))
    }

    @objc func headerRefresh() {
        let group = DispatchGroup()

        group.enter()
        HomePageHelper.getHomepage(success: { homepage in
            self.homepage = homepage
            self.tableView.reloadData()
            group.leave()
            // TODO: fix cache
//            Storage.
        }, failure: { error in
            group.leave()
        })

        group.enter()
        HomePageHelper.getGallery(success: { galleries in
            self.galleryList = galleries
            self.tableView.reloadData()
            group.leave()
        }, failure: { error in
            group.leave()
        })

        group.enter()
        HomePageHelper.getNews(page: page, category: category, success: { newsList in
            self.newsList = newsList.data
            group.leave()
            self.tableView.reloadData()
        }, failure: { error in
            group.leave()
        })

        group.notify(queue: .main, execute: {
            if self.tableView.mj_header.isRefreshing {
                self.tableView.mj_header.endRefreshing()
            }
        })
    }

    @objc func footerLoadMore() {
        let newCategory = category + 1
        if newCategory == 6 {
            category = 1
            page += 1
        } else {
            category = newCategory
        }

        self.tableView.mj_footer.beginRefreshing()
        HomePageHelper.getNews(page: page, category: category, success: { newsList in
            self.newsList += newsList.data
            self.tableView.reloadData()
            if self.tableView.mj_footer.isRefreshing {
                self.tableView.mj_footer.endRefreshing()
            }
        }, failure: { error in
            if self.tableView.mj_footer.isRefreshing {
                self.tableView.mj_footer.endRefreshing()
                if newCategory == 6 {
                    self.category = 5
                    self.page -= 1
                } else {
                    self.category -= 1
                }
            }
        })
    }
}


// MARK: - 使用contentoffset使label文字大小变化
extension NewsViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        print("scroll: \(scrollView.contentOffset.y)")
        let ScrollViewY = scrollView.contentOffset.y
        if ScrollViewY < 0 {
            self.newsHeaderView.navigationBarHiddenScrollByY(ScrollViewY - 130)
        } else {
            self.newsHeaderView.viewScrolledByY(ScrollViewY - 130)
        }
    }
}

extension NewsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3 + newsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        switch indexPath.row {
        case 0:
            // 在bannerBackView上添加一个“咨询”label 和轮播图
            let bannerBackView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 450))
            cell.contentView.addSubview(bannerBackView)
            bannerBackView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            let informationLabel = UILabel(text: "资讯", color: .black)
            informationLabel.font = UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.heavy)
            informationLabel.textAlignment = .left
            bannerBackView.addSubview(informationLabel)
            informationLabel.snp.makeConstraints({ (make) in
                make.top.equalToSuperview().offset(10)
                make.left.equalToSuperview().offset(25)
                make.width.equalTo(100)
                make.height.equalTo(40)
            })
            let bannerWidth: CGFloat = deviceWidth - 40
            let bannerHeight: CGFloat = 400
            bannerFooView = UIView(color: .white)
            bannerBackView.addSubview(bannerFooView)
//            cell.contentView.addSubview(bannerFooView)

            bannerFooView.snp.makeConstraints({ (make) in
//                make.top.equalToSuperview().offset(60)
                make.top.equalTo(informationLabel.snp.bottom).offset(20)
                make.left.equalToSuperview().offset(20)
                make.right.equalToSuperview().offset(-20)
                make.bottom.equalToSuperview().offset(-10)
                make.height.equalTo(bannerHeight)
                make.width.equalTo(bannerWidth)
            })
            bannerFooView.layer.cornerRadius = 15
            bannerFooView.layer.shadowRadius = 4
            bannerFooView.layer.shadowOffset = CGSize(width: 0, height: 2)

            bannerFooView.layer.shadowOpacity = 0.5
            if let homepage = self.homepage {
                let imgs = homepage.data.carousel.map { carousel in
                    return carousel.pic
                }

                let desc = homepage.data.carousel.map { carousel in
                    return carousel.subject
                }
                let bannerView = BannerScrollView(frame: CGRect(x: 0, y: 0, width: bannerWidth, height: bannerHeight), type: .SERVER, imgs: imgs, descs: desc, defaultDotImage: UIImage(named: "defaultDot"), currentDotImage: UIImage(named: "currentDot"))
                bannerView.layer.cornerRadius = 15
                bannerView.layer.masksToBounds = true
                bannerView.delegate = self
                bannerView.descLabelHeight = 150
                bannerView.descLabelFont = UIFont.boldSystemFont(ofSize: 25)
                bannerView.descLabelTextAlignment = .left
                bannerFooView.addSubview(bannerView)
//                bannerView.snp.makeConstraints { make in
//                    ma
//                }
            }

            // init 轮播图BannerView
        case 1:
            let titleLabel = UILabel(text: "图集", color: .black)
            titleLabel.font = UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.heavy)
            titleLabel.sizeToFit()
            titleLabel.textAlignment = .left
            cell.contentView.addSubview(titleLabel)
            titleLabel.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(10)
                make.left.equalToSuperview().offset(25)
                make.width.equalTo(100)
                make.height.equalTo(40)
            }

            let layout = UICollectionViewFlowLayout()
            layout.itemSize = CGSize(width: 130, height: 200)
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = 20

            let galleryView = UICollectionView(frame: CGRect(x: 0, y: 55, width: view.width, height: 200), collectionViewLayout: layout)

            galleryView.contentInset.left = 20
            galleryView.contentInset.right = 20
            galleryView.backgroundColor = .white
            galleryView.delegate = self
            galleryView.dataSource = self
            galleryView.showsVerticalScrollIndicator = false
            galleryView.showsHorizontalScrollIndicator = false
            galleryView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "galleryView")
            cell.contentView.addSubview(galleryView)
            galleryView.snp.makeConstraints { make in
                make.top.equalTo(titleLabel.snp.bottom).offset(20)
                make.bottom.left.right.equalToSuperview()
                make.width.equalToSuperview()
                make.height.equalTo(200)
            }
        case 2:
            let titleLabel = UILabel(text: "新闻", color: .black)
            titleLabel.font = UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.heavy)
            titleLabel.sizeToFit()
            titleLabel.textAlignment = .left
            cell.contentView.addSubview(titleLabel)
            titleLabel.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(10)
                make.left.equalToSuperview().offset(25)
                make.width.equalTo(100)
                make.height.equalTo(40)
                make.bottom.equalToSuperview()
            }
        case var row where row > 2 && row - 2 < newsList.count:
            row = row - 2
            let news = newsList[row]
            if URL(string: news.pic) != nil {
                cell = tableView.dequeueReusableCell(withIdentifier: "news-right") ??
                    NewsTableViewCell(style: .default, reuseIdentifier: "news-right", imageStyle: .right)
            } else {
                cell = tableView.dequeueReusableCell(withIdentifier: "news-none") ??
                    NewsTableViewCell(style: .default, reuseIdentifier: "news-none", imageStyle: .none)
            }

            if let cell = cell as? NewsTableViewCell {
                cell.titleLabel.text = news.subject
                cell.detailLabel.text = news.summary
                cell.descLabel.text = "阅读: \(news.visitcount) 评论: \(news.comments)"
                cell.imgView.sd_setImage(with: URL(string: news.pic), completed: nil)
                cell.imgView.sd_setIndicatorStyle(.gray)
                // FIXME: ActivityIndicator
                cell.imgView.sd_setShowActivityIndicatorView(true)
            }
        default:
            
            break
        }
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        return cell
    }
}

extension NewsViewController: UITableViewDelegate {
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 300
//    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return newsHeaderView
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 100
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row <= 2 {
            return
        }
        let row = indexPath.row - 2
        tableView.deselectRow(at: indexPath, animated: true)
        let news = newsList[row]
        let newsVC = ProgressWebViewController()
        newsVC.webView.load(URLRequest(url: URL(string: "https://news.twt.edu.cn/?c=default&a=pernews&id=" + news.index)!))
        self.navigationController?.pushViewController(newsVC, animated: true)
    }
}


extension NewsViewController: BannerScrollViewDelegate {
    func bannerScrollViewDidSelect(at index: Int, bannerScrollView: BannerScrollView) {
        if let homepage = self.homepage {
            let newsIndex = homepage.data.carousel[index].index
            // self.navigationController?.pushViewController(detailVC, animated: true)
        }
    }
}

extension NewsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return galleryList.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "galleryView", for: indexPath)

        let gallery = galleryList[indexPath.row]
        let imgView = UIImageView(frame: cell.bounds)
        imgView.contentMode = .scaleAspectFill
        imgView.layer.cornerRadius = 5
        imgView.clipsToBounds = true
        imgView.sd_setImage(with: URL(string: gallery.coverURL), completed: nil)
        let label = UILabel()
        label.text = gallery.title
        label.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.regular)
        label.textColor = .white
        label.sizeToFit()
        label.textAlignment = .center
        label.x = imgView.x
        label.height = label.height + 10
        label.y = imgView.y + imgView.height - label.height
        label.width = imgView.width
        label.adjustsFontSizeToFitWidth = true

        label.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6)
        imgView.addSubview(label)
        cell.contentView.addSubview(imgView)
        return cell
    }
}

extension NewsViewController: UICollectionViewDelegate {
}

