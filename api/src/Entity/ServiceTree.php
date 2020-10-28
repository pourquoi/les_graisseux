<?php

namespace App\Entity;

use ApiPlatform\Core\Annotation\ApiFilter;
use ApiPlatform\Core\Annotation\ApiProperty;
use ApiPlatform\Core\Annotation\ApiResource;
use ApiPlatform\Core\Annotation\ApiSubresource;
use App\Entity\Translation\ServiceTranslation;
use App\Repository\ServiceTreeRepository;
use Doctrine\Common\Collections\ArrayCollection;
use Doctrine\Common\Collections\Collection;
use Doctrine\ORM\Mapping as ORM;
use Locastic\ApiPlatformTranslationBundle\Model\AbstractTranslatable;
use Locastic\ApiPlatformTranslationBundle\Model\TranslationInterface;
use Symfony\Component\Serializer\Annotation\Groups;
use ApiPlatform\Core\Bridge\Doctrine\Orm\Filter\SearchFilter;

/**
 * @ApiResource(
 *     shortName="Service",
 *     normalizationContext={"groups"={"read", "service:read"}},
 *     denormalizationContext={"groups"={"write", "service:write"}},
 *     itemOperations={
 *       "get",
 *       "put"={
 *         "method"="PUT",
 *         "normalization_context"={"groups"={"write", "service:write", "translations"}},
 *         "security"="is_granted('ROLE_ADMIN')"
 *       }
 *     },
 *     collectionOperations={
 *       "get",
 *       "post"={
 *           "method"="POST",
 *           "normalization_context"={"groups"={"write", "service:write", "translations"}},
 *           "security_post_denormalize"="is_granted('ROLE_ADMIN')"
 *       }
 *     }
 * )
 * @ApiFilter(SearchFilter::class, properties={"translations.label": "word_start"})
 * @ORM\Entity(repositoryClass=ServiceTreeRepository::class)
 */
class ServiceTree extends AbstractTranslatable
{
    use Traits\PopularityTrait;

    /**
     * @ORM\Id
     * @ORM\GeneratedValue
     * @ORM\Column(type="integer")
     * @Groups({"read", "write"})
     * @ApiProperty(writable=false)
     */
    protected $id;

    /**
     * @var string
     * @Groups({"read"})
     */
    protected $label;

    /**
     * @var string
     * @Groups({"service:read"})
     */
    protected $description;

    /**
     * @var Collection|ServiceTree[]
     * @ORM\OneToMany(targetEntity="ServiceTree", mappedBy="parent")
     * @ApiSubresource()
     * @Groups({"service:read"})
     */
    protected $children;

    /**
     * @var ServiceTree
     * @ORM\ManyToOne(targetEntity="ServiceTree", inversedBy="children")
     * @Groups({"read", "service:write"})
     */
    protected $parent;

    /**
     * @var ServiceTree
     * @ORM\ManyToOne(targetEntity="ServiceTree")
     */
    protected $root;

    /**
     * @var ServiceTranslation
     * @ORM\OneToMany(targetEntity="App\Entity\Translation\ServiceTranslation", mappedBy="translatable", fetch="EXTRA_LAZY", indexBy="locale", cascade={"PERSIST"}, orphanRemoval=true)
     * @Groups({"service:write", "translations"})
     */
    protected $translations;

    public function __construct()
    {
        parent::__construct();
        $this->children = new ArrayCollection();
    }

    protected function createTranslation(): TranslationInterface
    {
        return new ServiceTranslation();
    }

    public function getId(): ?int
    {
        return $this->id;
    }

    public function getLabel(): ?string
    {
        return $this->getTranslation()->getLabel();
    }

    public function setLabel(string $label): self
    {
        $this->getTranslation()->setLabel($label);
        return $this;
    }

    public function getDescription(): ?string
    {
        return $this->getTranslation()->getDescription();
    }

    public function setDescription(?string $description): self
    {
        $this->getTranslation()->setDescription($description);
        return $this;
    }

    public function getParent(): ?ServiceTree
    {
        return $this->parent;
    }

    private function _ensureTreeIntegrity() {
        if( $this->parent == null ) {
            $this->root = null;
        } else if( $this->parent->getRoot() === null ) {
            $this->root = $this->parent;
        } else if( $this->parent->getRoot() !== $this->root ) {
            $this->root = $this->parent->getRoot();
        }
    }

    public function setParent(?ServiceTree $parent): self
    {
        $this->parent = $parent;
        $this->_ensureTreeIntegrity();
        return $this;
    }

    public function getRoot(): ?ServiceTree
    {
        return $this->root;
    }

    public function setRoot(?ServiceTree $root): self
    {
        $this->root = $root;
        $this->_ensureTreeIntegrity();
        return $this;
    }

    public function getChildren(): Collection
    {
        return $this->children;
    }

    public function addChild(ServiceTree $child): self
    {
        if( !$this->children->contains($child) ) {
            $this->children->add($child);
        }

        return $this;
    }

    public function removeChild(ServiceTree $child): self
    {
        if( $this->children->contains($child) ) {
            $this->children->remove($child);
        }

        return $this;
    }

}
